-- climbglove/init.lua

local jumpno = 0

minetest.register_craftitem("climbglove:climb_glove", {
			       description = "A glove for climbing walls",
			       inventory_image = "climbglove.png",
			       sound = {breaks = "default_tool_breaks"},
			       on_use = function(itemstack, user, pointed_thing)
				  local sound_pos = user:get_pos()
				  if sound_pos == nil then
				     return
				  end

				  if pointed_thing.type ~= "node" then
				     return itemstack
				  end

				  if user:get_velocity().y == 0 then
				     jumpno = 0
				  end
				  user:add_velocity({x=0,y=6.5,z=0})				  
				  minetest.sound_play("dhit1", {pos = sound_pos, gain = 1.5, max_hear_distance = 8}, true) 
				  return itemstack
			       end
})

