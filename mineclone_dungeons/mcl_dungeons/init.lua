-- FIXME: Chests may appear at openings

local debug_mode = true

mcl_dungeons = {}

-- Are dungeons disabled?
if mcl_mapgen.dungeons == false or mcl_mapgen.singlenode == true then
	return
end

--lua locals
--minetest
local minetest_find_nodes_in_area = minetest.find_nodes_in_area
local registered_nodes = minetest.registered_nodes
local swap_node        = minetest.swap_node
local set_node         = minetest.set_node
local dir_to_facedir   = minetest.dir_to_facedir
local get_meta         = minetest.get_meta

--vector
local vector_add       = vector.add
local vector_subtract  = vector.subtract

--table
local table_insert     = table.insert
local table_sort       = table.sort

--math
local math_min         = math.min
local math_max         = math.max
local math_ceil        = math.ceil

--custom mcl_vars
local get_node = mcl_mapgen.get_far_node


local min_y = math_max(mcl_mapgen.overworld.min, mcl_mapgen.overworld.bedrock_max) + 1
local max_y = mcl_mapgen.overworld.max - 1
-- Calculate the number of dungeon spawn attempts
-- In Minecraft, there 8 dungeon spawn attempts Minecraft chunk (16*256*16 = 65536 blocks).
-- Minetest chunks don't have this size, so scale the number accordingly.
local attempts = math_ceil((mcl_mapgen.CS_NODES ^ 3) / 8192) -- 63 = 80*80*80/8192

local dungeonsizes = {
	{ x=5, y=4, z=5},
	{ x=5, y=4, z=7},
	{ x=7, y=4, z=5},
	{ x=7, y=4, z=7},
}

--[[local dirs = {
	{ x= 1, y=0, z= 0 },
	{ x= 0, y=0, z= 1 },
	{ x=-1, y=0, z= 0 },
	{ x= 0, y=0, z=-1 },
}]]

local surround_vectors = {
	{ x=-1, y=0, z=0 },
	{ x=1, y=0, z=0 },
	{ x=0, y=0, z=-1 },
	{ x=0, y=0, z=1 },
}

local loottable = {
   {
      stacks_min = 1,
      stacks_max = 4,
      items = {
	 { itemstring = "mcl_mobs:nametag", weight = 20 },
	 { itemstring = "farming:carrot", weight = 20, amount_min = 5, amount_max = 15 },
	 { itemstring = "mcl_mobitems:saddle", weight = 20 },
	 { itemstring = "mcl_buckets:bucket_empty", weight = 15 },
	 { itemstring = "mobs_mc:parrot", weight = 15 },
	 { itemstring = "vines:rope_block", weight = 15 },
	 { itemstring = "airtanks:breathing_tube", weight = 15 },
	 { itemstring = "balloonblocks:pink", weight = 15 },
	 { itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 5, amount_max = 15 },
	 { itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 5, amount_max = 15 },
	 { itemstring = "mobs_mc:iron_horse_armor", weight = 15 },
	 { itemstring = "mcl_core:apple_gold", weight = 15, amount_min = 1, amount_max = 4},
	 { itemstring = "mobs_mc:gold_horse_armor", weight = 10 },
	 { itemstring = "mobs_mc:diamond_horse_armor", weight = 5 }
      }
   },
   {
      stacks_min = 1,
      stacks_max = 3,
      items = {
	 { itemstring = "ctf_ranged:gunpart1", weight = 20},
	 { itemstring = "drug_wars:machete_steel", weight = 20},
	 { itemstring = "ctf_ranged:mini14", weight = 20 },
	 { itemstring = "ctf_ranged:glock17", weight = 20},
	 { itemstring = "ctf_ranged:uzi", weight = 20},
	 { itemstring = "ctf_ranged:python", weight = 20},
	 { itemstring = "ctf_ranged:makarov", weight = 20},
	 { itemstring = "ctf_ranged:ak47", weight = 20},
	 { itemstring = "ctf_ranged:40mm", weight = 20, amount_min = 1, amount_max = 10},
	 { itemstring = "ctf_ranged:ammo", weight = 20, amount_min = 1, amount_max = 10},
	 { itemstring = "ctf_ranged:eammo", weight = 20, amount_min = 1, amount_max = 10}
      }
   },
   {
      stacks_min = 0,
      stacks_max = 1,
      items = {
	 { itemstring = "mcl_jukebox:record_13", weight = 10 },
	 { itemstring = "mcl_jukebox:record_blocks", weight = 10 },
	 { itemstring = "mcl_jukebox:record_chirp", weight = 10 },
	 { itemstring = "mcl_jukebox:record_far", weight = 10 },
	 { itemstring = "mcl_jukebox:record_mall", weight = 10 },
	 { itemstring = "mcl_jukebox:record_mellohi", weight = 10 },
	 { itemstring = "mcl_jukebox:record_strad", weight = 10 },
	 { itemstring = "mcl_jukebox:record_wait", weight = 10 },
      },
   },
   
}

-- Bonus loot for v6 mapgen: Otherwise unobtainable saplings.
if mcl_mapgen.v6 then
	table.insert(loottable, {
		stacks_min = 1,
		stacks_max = 3,
		items = {
			{ itemstring = "mcl_core:birchsapling", weight = 1, amount_min = 1, amount_max = 2 },
			{ itemstring = "mcl_core:acaciasapling", weight = 1, amount_min = 1, amount_max = 2 },
			{ itemstring = "", weight = 6 },
		},
	})
end

--local function ecb_spawn_dungeon(blockpos, action, calls_remaining, param)
--	if calls_remaining >= 1 then return end
--	local p1, _, dim, pr = param.p1, param.p2, param.dim, param.pr
--	local check = not (param.dontcheck or false)


local m1, m2 = 0, 0
local function spawn_dungeon(p1, p2, dim, pr, dontcheck)
	local x, y, z = p1.x, p1.y, p1.z
	local check = not (dontcheck or false)

	-- Check floor and ceiling: Must be *completely* solid
	local y_floor = y
	local y_ceiling = y + dim.y + 1

	if check then
		local dim_x, dim_z = dim.x, dim.z
		local size = dim_z*dim_x
		local nodes_floor = #minetest_find_nodes_in_area({x=x+1,y=y_floor,z=z+1}, {x=x+dim_z,y=y_floor,z=z+dim_z},
		   {"group:crumbly", "group:cracky"})
		local nodes_ceil = #minetest_find_nodes_in_area({x=x+1,y=y_ceiling,z=z+1}, {x=x+dim_z,y=y_floor,z=z+dim_z},
		   {"group:crumbly", "group:cracky"})

		if nodes_floor < size or nodes_ceil < size then
		   return
		end
	end
	-- Check for air openings (2 stacked air at ground level) in wall positions
	local openings_counter = 0
	-- Store positions of openings; walls will not be generated here
	local openings = {}
	-- Corners are stored because a corner-only opening needs to be increased,
	-- so entities can get through.
	local corners = {}

	local x2,z2 = x+dim.x+1, z+dim.z+1

	if get_node({x=x, y=y+1, z=z}).name == "air" and get_node({x=x, y=y+2, z=z}).name == "air" then
		openings_counter = openings_counter + 1
		if not openings[x] then openings[x]={} end
		openings[x][z] = true
		table_insert(corners, {x=x, z=z})
	end
	if get_node({x=x2, y=y+1, z=z}).name == "air" and get_node({x=x2, y=y+2, z=z}).name == "air" then
		openings_counter = openings_counter + 1
		if not openings[x2] then openings[x2]={} end
		openings[x2][z] = true
		table_insert(corners, {x=x2, z=z})
	end
	if get_node({x=x, y=y+1, z=z2}).name == "air" and get_node({x=x, y=y+2, z=z2}).name == "air" then
		openings_counter = openings_counter + 1
		if not openings[x] then openings[x]={} end
		openings[x][z2] = true
		table_insert(corners, {x=x, z=z2})
	end
	if get_node({x=x2, y=y+1, z=z2}).name == "air" and get_node({x=x2, y=y+2, z=z2}).name == "air" then
		openings_counter = openings_counter + 1
		if not openings[x2] then openings[x2]={} end
		openings[x2][z2] = true
		table_insert(corners, {x=x2, z=z2})
	end

	for wx = x+1, x+dim.x do
		if get_node({x=wx, y=y+1, z=z}).name == "air" and get_node({x=wx, y=y+2, z=z}).name == "air" then
			openings_counter = openings_counter + 1
			if check and openings_counter > 5 then return end
			if not openings[wx] then openings[wx]={} end
			openings[wx][z] = true
		end
		if get_node({x=wx, y=y+1, z=z2}).name == "air" and get_node({x=wx, y=y+2, z=z2}).name == "air" then
			openings_counter = openings_counter + 1
			if check and openings_counter > 5 then return end
			if not openings[wx] then openings[wx]={} end
			openings[wx][z2] = true
		end
	end
	for wz = z+1, z+dim.z do
		if get_node({x=x, y=y+1, z=wz}).name == "air" and get_node({x=x, y=y+2, z=wz}).name == "air" then
			openings_counter = openings_counter + 1
			if check and openings_counter > 5 then return end
			if not openings[x] then openings[x]={} end
			openings[x][wz] = true
		end
		if get_node({x=x2, y=y+1, z=wz}).name == "air" and get_node({x=x2, y=y+2, z=wz}).name == "air" then
			openings_counter = openings_counter + 1
			if check and openings_counter > 5 then return end
			if not openings[x2] then openings[x2]={} end
			openings[x2][wz] = true
		end
	end

	-- If all openings are only at corners, the dungeon can't be accessed yet.
	-- This code extends the openings of corners so they can be entered.
	if openings_counter >= 1 and openings_counter == #corners then
		for c=1, #corners do
			-- Prevent creating too many openings because this would lead to dungeon rejection
			if openings_counter >= 5 then
				break
			end
			-- A corner is widened by adding openings to both neighbors
			local cx, cz = corners[c].x, corners[c].z
			local cxn, czn = cx, cz
			if x == cx then
				cxn = cxn + 1
			else
				cxn = cxn - 1
			end
			if z == cz then
				czn = czn + 1
			else
				czn = czn - 1
			end
			openings[cx][czn] = true
			openings_counter = openings_counter + 1
			if openings_counter < 5 then
				if not openings[cxn] then openings[cxn]={} end
				openings[cxn][cz] = true
				openings_counter = openings_counter + 1
			end
		end
	end

	-- Check conditions. If okay, start generating
	if check and (openings_counter < 1 or openings_counter > 5) then return end
	
	minetest.log("action","[mcl_dungeons] Placing new dungeon at "..minetest.pos_to_string({x=x,y=y,z=z}))
	-- Okay! Spawning starts!

	-- Remember spawner chest positions to set metadata later
	local chests = {}
	local spawner_posses = {}

	-- First prepare random chest positions.
	-- Chests spawn at wall

	-- We assign each position at the wall a number and each chest gets one of these numbers randomly
	local totalChests = 2 -- this code strongly relies on this number being 2
	local totalChestSlots = (dim.x + dim.z - 2) * 2
	local chestSlots = {}
	-- There is a small chance that both chests have the same slot.
	-- In that case, we give a 2nd chance for the 2nd chest to get spawned.
	-- If it failed again, tough luck! We stick with only 1 chest spawned.
	local lastRandom
	local secondChance = true -- second chance is still available
	for i=1, totalChests do
		local r = pr:next(1, totalChestSlots)
		if r == lastRandom and secondChance then
			-- Oops! Same slot selected. Try again.
			r = pr:next(1, totalChestSlots)
			secondChance = false
		end
		lastRandom = r
		table_insert(chestSlots, r)
	end
	table_sort(chestSlots)
	local currentChest = 1

	-- Calculate the mob spawner position, to be re-used for later
	local sp = {x = x + math_ceil(dim.x/2), y = y+1, z = z + math_ceil(dim.z/2)}
	local rn = registered_nodes[get_node(sp).name]
	if rn and rn.is_ground_content then
		table_insert(spawner_posses, sp)
	end

	-- Generate walls and floor
	local maxx, maxy, maxz = x+dim.x+1, y+dim.y, z+dim.z+1
	local chestSlotCounter = 1
	for tx = x, maxx do
	for tz = z, maxz do
	for ty = y, maxy do
		local p = {x = tx, y=ty, z=tz}

		-- Do not overwrite nodes with is_ground_content == false (e.g. bedrock)
		-- Exceptions: cobblestone and mossy cobblestone so neighborings dungeons nicely connect to each other
		local name = get_node(p).name
		if registered_nodes[name].is_ground_content or name == "mcl_core:cobble" or name == "mcl_core:mossycobble" then
			-- Floor
			if ty == y then
				if pr:next(1,4) == 1 then
					swap_node(p, {name = "mcl_core:cobble"})
				else
					swap_node(p, {name = "mcl_core:mossycobble"})
				end

				-- Generate walls
				--[[ Note: No additional cobblestone ceiling is generated. This is intentional.
				The solid blocks above the dungeon are considered as the “ceiling”.
				It is possible (but rare) for a dungeon to generate below sand or gravel. ]]

			elseif tx == x or tz == z or tx == maxx or tz == maxz then
				-- Check if it's an opening first
				if (ty == maxy) or (not (openings[tx] and openings[tx][tz]))  then
					-- Place wall or ceiling
					swap_node(p, {name = "mcl_core:cobble"})
				elseif ty < maxy - 1 then
					-- Normally the openings are already clear, but not if it is a corner
					-- widening. Make sure to clear at least the bottom 2 nodes of an opening.
					if name ~= "air" then swap_node(p, {name = "air"}) end
				elseif name ~= "air" then
					-- This allows for variation between 2-node and 3-node high openings.
					swap_node(p, {name = "mcl_core:cobble"})
				end
				-- If it was an opening, the lower 3 blocks are not touched at all

			-- Room interiour
			else
				if (ty==y+1) and (tx==x+1 or tx==maxx-1 or tz==z+1 or tz==maxz-1) and (currentChest < totalChests + 1) and (chestSlots[currentChest] == chestSlotCounter) then
					currentChest = currentChest + 1
					table_insert(chests, {x=tx, y=ty, z=tz})
				else
					swap_node(p, {name = "air"})
				end

				local forChest = ty==y+1 and (tx==x+1 or tx==maxx-1 or tz==z+1 or tz==maxz-1)

				-- Place next chest at the wall (if it was its chosen wall slot)
				if forChest and (currentChest < totalChests + 1) and (chestSlots[currentChest] == chestSlotCounter) then
					currentChest = currentChest + 1
					table_insert(chests, {x=tx, y=ty, z=tz})
				-- else
					--swap_node(p, {name = "air"})
				end
				if forChest then
					chestSlotCounter = chestSlotCounter + 1
				end
			end
		end
	end end end

	for c=#chests, 1, -1 do
		local pos = chests[c]

		local surroundings = {}
		for s=1, #surround_vectors do
			-- Detect the 4 horizontal neighbors
			local spos = vector_add(pos, surround_vectors[s])
			local wpos = vector_subtract(pos, surround_vectors[s])
			local nodename = get_node(spos).name
			local nodename2 = get_node(wpos).name
			local nodedef = registered_nodes[nodename]
			local nodedef2 = registered_nodes[nodename2]
			-- The chest needs an open space in front of it and a walkable node (except chest) behind it
			if nodedef and nodedef.walkable == false and nodedef2 and nodedef2.walkable == true and nodename2 ~= "mcl_chests:chest" then
				table_insert(surroundings, spos)
			end
		end
		-- Set param2 (=facedir) of this chest
		local facedir
		if #surroundings <= 0 then
			-- Fallback if chest ended up in the middle of a room for some reason
			facedir = pr:next(0, 0)
		else
			-- 1 or multiple possible open directions: Choose random facedir
			local face_to = surroundings[pr:next(1, #surroundings)]
			facedir = dir_to_facedir(vector_subtract(pos, face_to))
		end

		set_node(pos, {name="mcl_chests:chest", param2=facedir})
		local meta = get_meta(pos)
		minetest.log("action", "[mcl_dungeons] Filling chest " .. tostring(c) .. " at " .. minetest.pos_to_string(pos))
		mcl_loot.fill_inventory(meta:get_inventory(), "main", mcl_loot.get_multi_loot(loottable, pr), pr)
	end

	-- Mob spawners are placed seperately, too
	-- We don't want to destroy non-ground nodes
	for s=#spawner_posses, 1, -1 do
		local sp = spawner_posses[s]
		-- ... and place it and select a random mob
		set_node(sp, {name = "mcl_mobspawners:spawner"})
		local mobs = {
			"mobs_mc:zombie",
			"mobs_mc:zombie",
			"mobs_mc:spider",
			"mobs_mc:skeleton",
		}
		local spawner_mob = mobs[pr:next(1, #mobs)]

		mcl_mobspawners.setup_spawner(sp, spawner_mob, 0, 7)
	end
end

local function dungeons_nodes(minp, maxp, blockseed)
	local ymin, ymax = math_max(min_y, minp.y),  math_min(max_y, maxp.y)
	if ymax < ymin then return false end
	local pr = PseudoRandom(blockseed)
	for a=1, attempts do
		local dim = dungeonsizes[pr:next(1, #dungeonsizes)]
		local x = pr:next(minp.x, maxp.x-dim.x-1)
		local y = pr:next(ymin  , ymax  -dim.y-1)
		local z = pr:next(minp.z, maxp.z-dim.z-1)
		local p1 = {x=x,y=y,z=z}
		local p2 = {x = x+dim.x+1, y = y+dim.y+1, z = z+dim.z+1}
		spawn_dungeon(p1, p2, dim, pr)
	end
end

function mcl_dungeons.spawn_dungeon(p1, _, pr)
	if not p1 or not pr or not p1.x or not p1.y or not p1.z then return end
	local dim = dungeonsizes[pr:next(1, #dungeonsizes)]
	local p2 = {x = p1.x+dim.x+1, y = p1.y+dim.y+1, z = p1.z+dim.z+1}
	spawn_dungeon(p1, p2, dim, pr, true)
end

mcl_mapgen.register_mapgen(dungeons_nodes, mcl_mapgen.order.DUNGEONS)
