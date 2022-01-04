-- This is a stripped-down and modified version of this mod:
-- https://github.com/bas080/pathogen/tree/master/pathogen
--

xpanes.register_pane("pathogen:fence_warning", {
			description = "Infection Hazard Fence",
			tiles = {"pathogen_fence.png"},
			drawtype = "airlike",
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			pointable = false,
			diggable = false,
			buildable_to = true,
			air_equivalent = true,
			textures = {"pathogen_fence.png", "pathogen_fence.png", 'xpanes_space.png'},
			inventory_image = "pathogen_fence.png",
			wield_image = "pathogen_fence.png",
			groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3, pane=1},
			recipe = {
			   {'group:stick', '', 'group:stick'},
			   {'group:stick', 'dye:red', 'group:stick'},
			   {'group:stick', '', 'group:stick'}
			}

})

minetest.register_craft({
      output = "pathogen:fence_warning",
      recipe = {
	 {'group:stick', '', 'group:stick'},
	 {'group:stick', 'dye:red', 'group:stick'},
	 {'group:stick', '', 'group:stick'}
      }
})


minetest.register_tool( 'pathogen:decontaminator', {
			   description = 'Decontaminator',

			   inventory_image = "pathogen_decontaminator.png",
			   on_use = function(itemstack, user, pt)

			      local p = user:get_pos()
			      if p == nil then
				 return itemstack
			      end
			      minetest.sound_play( "pathogen_spray", {pos = p, gain = 1.0, max_hear_distance = 8}, true)
			      if pt.type ~= "node" then
				 return itemstack
			      end
			      print(pt.type)
			      local rando = math.random(5)
			      if rando == 1 then
				 return itemstack
			      end
			      --pathogen.decontaminate( pt.under )
			   end
})

minetest.register_craft({
      output = "pathogen:decontaminator",
      recipe = {
	 {'default:steel_ingot','',''},
	 {'','default:steelblock',''},
	 {'','',''}
      }
})
