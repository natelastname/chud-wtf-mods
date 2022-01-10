-- covid19/init.lua


covid19 = {}
covid19.path = minetest.get_modpath("covid19")

dofile(covid19.path.."/mask.lua")
dofile(covid19.path.."/pathogen.lua")

-- This will hopefully not break worlds with existing pathogen items
minetest.register_alias("mask:mask", "covid19:mask")
minetest.register_alias("pathogen:decontaminator", "covid19:decontaminator")
minetest.register_alias("pathogen:fence_warning", "covid19:fence_warning")


local ExplosiveProjectile = {
   initial_properties = {
      physical = true,
      collide_with_objects = false,
      collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
      visual = "wielditem",
      visual_size = {x = 0.4, y = 0.4},
      textures = {""},
      spritediv = {x = 1, y = 1},
      initial_sprite_basepos = {x = 0, y = 0},
   },
   owner_name = nil,
   pos = nil,
   vel = nil
}


local function get_gravity()
   return tonumber(minetest.settings:get("movement_gravity")) or 9.81
end

function ExplosiveProjectile:on_step(dtime, moveresult)

   --self.object:add_velocity({x=0,y=-9.81*dtime,z=0})
   local arr = moveresult.collisions
   for i,x in pairs(arr) do
      if x.type == "node" then
	 local p = self.object:get_pos()
	 -- This nil check is very important
	 -- Always nil check the result of get_pos()
	 if p == nil then
	    return
	 end
	 self.object:remove()
	 -- Don't pass the name of the owner because we want
	 -- players to be able to grief eachother using this.
	 
	 --[[
	 bombutil.boom(p, self.owner_name, {
			  radius=3,
			  explode_center=true,
			  ignore_protection=false,
			  ignore_on_blast_ents=true,
			  ignore_on_blast_nodes=true,
			  sound="tnt_explode",
			  disable_drops=true
	 })
	 ]]--
	 bombutil.boom(p, "", {
			  radius=3,
			  explode_center=true,
			  ignore_protection=false,
			  ignore_on_blast_ents=true,
			  ignore_on_blast_nodes=true,
			  sound="tnt_explode",
			  disable_drops=true
	 })
      end
   end   
   
end

function ExplosiveProjectile:get_staticdata()

   return minetest.serialize({
	 pos=self.pos,
	 vel=self.vel,
	 owner_name=self.owner_name
   })
end

function ExplosiveProjectile:on_activate(staticdata, dtime_s)
   self.object:set_armor_groups({immortal = 1})

   local data
   if staticdata ~= "" and staticdata ~= nil then
      data = minetest.deserialize(staticdata) or {}
   end
   
   self.owner_name = data.owner_name
   self.vel = data.vel
   self.pos = data.pos

   if self.owner_name == nil or self.vel == nil or self.pos == nil then
      -- entity is corrupt.
      print(self.owner_name)
      print(minetest.pos_to_string(self.pos))
      print(minetest.pos_to_string(self.vel))
      minetest.log("warning", "A covid19:ExplosiveProjectile instance is corrupt, removing.")
      self.object:remove()
      return
   end
   
   self.object:set_velocity(self.vel)
   self.object:set_acceleration({x=0,y=-get_gravity(),z=0})
end


-- Owner is a reference to the player who owns the projectile
function LaunchExplosiveProjectile(pos, vel, owner_name)
   local staticdata = minetest.serialize({
	 pos=pos,
	 vel=vel,
	 owner_name=owner_name
   })
   minetest.add_entity(pos, "covid19:ExplosiveProjectile", staticdata)
end


minetest.register_entity("covid19:ExplosiveProjectile", ExplosiveProjectile)


minetest.register_craftitem("covid19:vaccine_jj", {
			       description = "Vaccine (J&J)",
			       inventory_image = "covid19_vaccine_jj.png",
			       sound = {breaks = "default_tool_breaks"},
			       on_use = function(itemstack, user, pointed_thing)
				  local sound_pos = user:get_pos()
				  if sound_pos == nil then
				     return
				  end
				  minetest.sound_play("smg-1", {pos = sound_pos, gain = 1.5, max_hear_distance = 8}, true)
				  local player_name = user:get_player_name()			     
				  local eye_offset = {x=0, y=1.625, z=0}
				  local anim = user:get_local_animation()

				  -- There is a really stupid bug here (it won't recognize vector addition, but only on the server.)
				  -- don't try to refactor these next 4 lines or the rest of this function
				  local lookdir = user:get_look_dir()
				  local p = vector.new(eye_offset.x + sound_pos.x + lookdir.x,
						       eye_offset.y + sound_pos.y + lookdir.y,
						       eye_offset.z + sound_pos.z + lookdir.z)
				  
				  minetest.add_particle({
					pos = p,
					velocity = lookdir,
					acceleration = vector.new(),
					expirationtime = 0.4,
					size = 5,
					collisiondetection = false,
					vertical = true,
					texture = "tnt_smoke.png",
					glow = 15,
				  })

				  local pos = user:get_pos()
				  if pos == nil then
				     return
				  end
				  pos = vector.add(vector.new(pos), vector.new({x=0,y=1.625,z=0}))
				  local vel = vector.add(vector.new(user:get_velocity()), vector.new(lookdir.x*20, lookdir.y*20, lookdir.z*20))

				  LaunchExplosiveProjectile(pos, vel, user:get_player_name())
				  
				  if minetest.is_creative_enabled(player_name) then
				     return itemstack
				  end
				  
				  itemstack:take_item()
				  return itemstack
			       end
})


minetest.register_craft({
      output = "covid19:vaccine_jj",
      recipe = {
	 {"", "", ""},
	 {"", "default:paper", "default:paper"},
	 {"", "", ""},
      }
})
