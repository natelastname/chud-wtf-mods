-- auto_place_spawn/init.lua

local storage = minetest.get_mod_storage()




local function place_spawn()
   print("Place spawn")
end

local function check_filename(name)
   return name:find("^[%w%s%^&'@{}%[%],%$=!%-#%(%)%%%.%+~_]+$") ~= nil
end
worldedit.register_command("place_spawn", {
			      params = "<file>",
			      description = "",
			      privs = {["worldedit"]=true},
			      require_pos = 1,
			      parse = function(param)
				 
				 local found, _, filename, radius  = param:find("^([^%s]+)%s+(%d+)$")

				 if found == nil then
				    return false
				 end
				 
				 if filename == "" then
				    return false
				 end
				 if not check_filename(filename) then
				    return false, "Disallowed file name: " .. filename
				 end
				 return true, filename, radius 
			      end,
			      func = function(name, fname, radius)
				 local pos = worldedit.pos1[name]
				 local path = minetest.get_worldpath() .. "/schems/" .. fname .. ".mts"

				 local schematic = minetest.read_schematic(path, {})

				 if schematic == nil then
				    worldedit.player_notify(name, "Could not open file ".. path)
				    return
				 end
				 
				 -- p1, p2 = bounding box of schematic				 
				 local p1 = vector.new({x=math.floor(schematic.size.x / 2), y=0, z=math.floor(schematic.size.z/2)})
				 local p2 = vector.new({x=-1*math.floor(schematic.size.x / 2), y=schematic.size.y, z=-1*math.floor(schematic.size.z/2)})
				 p1 = vector.add(p1, pos)
				 p2 = vector.add(p2, pos)


				 local outer_flat_p1 = vector.new()
				 local outer_flat_p2 = vector.new()

				 -- depth = how deep the flat layer surrounding spawn goes
				 local depth = 10

				 if radius ~= 0 then
				    outer_flat_p1.x = p1.x + radius
				    outer_flat_p1.y = p1.y
				    outer_flat_p1.z = p1.z + radius

				    outer_flat_p2.x = p2.x - radius
				    outer_flat_p2.y = p1.y - depth
				    outer_flat_p2.z = p2.z - radius
				    
				    -- Clear the space above the flat region surrounding spawn.
				    -- Notice the constant 200 here- this determines how many layers to clear
				    worldedit.set(vector.add(outer_flat_p1, vector.new({x=0,y=1,z=0})),
						  vector.add(outer_flat_p2, vector.new({x=0,y=200,z=0})),
						  "air")


				    worldedit.set(outer_flat_p1, outer_flat_p2, "default:cobble")
				    
				 end


				 
				 local flags = {
				    place_center_x=true,
				    place_center_y=false,
				    place_center_z=true
				 }
				 local result = minetest.place_schematic(pos, path, 0, {}, true, flags)
				 
				 -- Place mese blocks at the bounding corners of the spawn schematic
				 --minetest.set_node(p1, {name="default:mese"})
				 --minetest.set_node(p2, {name="default:mese"})
				 
				 if result == nil then
				    worldedit.player_notify(name, "failed to place Minetest schematic")
				 else
				    worldedit.player_notify(name, "placed Minetest schematic " .. fname ..
							       " at " .. minetest.pos_to_string(pos))
				 end
			      end,
})


minetest.register_on_newplayer(function(player)
      --place_spawn()
end)
