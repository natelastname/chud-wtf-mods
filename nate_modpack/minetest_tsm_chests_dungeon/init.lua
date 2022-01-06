-- Preciousness scaling numbers
local h_min = 256	-- Minimum height. At this height and below, the preciousness is at its peak
local h_max = 500	-- Max. height. At this height and above, the preciousness is at its lowest level

minetest.set_gen_notify("dungeon")
minetest.register_on_generated(function(minp, maxp, seed)
	local g = minetest.get_mapgen_object("gennotify")
	if g and g.dungeon and #g.dungeon > 3 then
		minetest.after(3, function(d)
			if d == nil or #d < 1 then
				return
			end
			for i=1,2 do
				local p = d[math.random(1, #d)]
				if minetest.get_node({x=p.x, y =p.y-1, z=p.z}).name ~= "air" then
					minetest.set_node(p, {name = "default:chest"})

					-- calculate preciousness of treasures based on height. higher = more precious
					local height = math.abs(h_min) - math.abs(h_max)
					local y_norm = (p.y+1) - h_min
					local scale = 1 - (y_norm/height)

					-- We will select randomly 1-2 out of 5 possible treasure groups: light, crafting component, building block, and melee weapon
					local groups = {
					   { 5, 0, 10, "default_dungeon_loot" }, -- precousness: 0..10
					}

					local meta = minetest.get_meta(p)
					local inv = meta:get_inventory()
					local treasures_added = 0
					for j=1, math.random(1, 2) do
						local r = math.random(1, #groups)
						local treasures = treasurer.select_random_treasures(groups[r][1], groups[r][2], groups[r][3], { groups[r][4] })
						treasures_added = treasures_added + #treasures
						for t=1,#treasures do
							inv:add_item("main", treasures[t])
						end
					end
					-- No treasures found? Maybe add one random treasure from default group
					if treasures_added <= 0 then
						if math.random(1,2) then
							local treasures = treasurer.select_random_treasures(1, 0, 4)
							for t=1,#treasures do
								inv:add_item("main", treasures[t])
							end
						end
					end
				end
			end
		end, table.copy(g.dungeon))
	end
end)

