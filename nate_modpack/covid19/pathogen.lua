-- This is a stripped-down and modified version of this mod:
-- https://github.com/bas080/pathogen/tree/master/pathogen
--

xpanes.register_pane("covid19:fence_warning", {
			description = "Infection Hazard Fence",
			tiles = {"covid19_fence.png"},
			drawtype = "airlike",
			paramtype = "light",
			sunlight_propagates = true,
			walkable = false,
			pointable = false,
			diggable = false,
			buildable_to = true,
			air_equivalent = true,
			textures = {"covid19_fence.png", "covid19_fence.png", 'xpanes_space.png'},
			inventory_image = "covid19_fence.png",
			wield_image = "covid19_fence.png",
			groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3, pane=1},
			recipe = {
			   {'group:stick', '', 'group:stick'},
			   {'group:stick', 'dye:red', 'group:stick'},
			   {'group:stick', '', 'group:stick'}
			}

})

minetest.register_craft({
      output = "covid19:fence_warning",
      recipe = {
	 {'group:stick', '', 'group:stick'},
	 {'group:stick', 'dye:red', 'group:stick'},
	 {'group:stick', '', 'group:stick'}
      }
})


minetest.register_tool( 'covid19:decontaminator', {
			   description = 'Decontaminator',

			   inventory_image = "covid19_decontaminator.png",
			   on_use = function(itemstack, user, pt)

			      local p = user:get_pos()
			      if p == nil then
				 return itemstack
			      end
			      local rando = math.random(5)
			      if rando == 1 then
				 minetest.sound_play( "covid19_alarm", {pos = p, gain = 1.0, max_hear_distance = 150}, true)
				 --[[
				 bombutil.boom(p, user:get_player_name(), {
						  radius=4,
						  explode_center=true,
						  ignore_protection=false,
						  ignore_on_blast_ents=true,
						  ignore_on_blast_nodes=true,
						  sound="tnt_explode",
						  disable_drops=true
				 })
				 ]]--
				 bombutil.boom(p, "", {
						  radius=0,
						  explode_center=true,
						  ignore_protection=false,
						  ignore_on_blast_ents=true,
						  ignore_on_blast_nodes=true,
						  sound="tnt_explode",
						  disable_drops=true
				 })

				 user:punch(user, nil, {
					       full_punch_interval=1.5,
					       max_drop_level=1,
					       groupcaps={
						  crumbly={maxlevel=2, uses=20, times={[1]=1.60, [2]=1.20, [3]=0.80}}
					       },
					       damage_groups = {fleshy=20}
						       }, vector.new(0,-1,0))
				 itemstack:add_wear(70000)
				 return itemstack
			      end
			      minetest.sound_play( "covid19_spray", {pos = p, gain = 1.0, max_hear_distance = 8}, true)
			      return itemstack
			   end
})

minetest.register_craft({
      output = "covid19:decontaminator",
      recipe = {
	 {'default:steel_ingot','',''},
	 {'','default:steelblock',''},
	 {'','',''}
      }
})
