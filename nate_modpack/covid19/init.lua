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
   def = nil
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
	 bombutil.boom(p, "", {
			  radius=1,
			  explode_center=true,
			  ignore_protection=false,
			  ignore_on_blast_ents=true,
			  ignore_on_blast_nodes=true,
			  sound="tnt_explode",
			  disable_drops=true
	 })
	 ]]--

	 explosions.explode(p, {
			       strength=self.def.blast_strength,
			       radius=self.def.blast_radius
	 })
	 bombutil.boom(p, "", {
			  radius=self.def.blast_radius
	 })
	 
      end
   end   
   
end

function ExplosiveProjectile:get_staticdata()
   return minetest.serialize({def=self.def})
end

function ExplosiveProjectile:on_activate(staticdata, dtime_s)
   self.object:set_armor_groups({immortal = 1})

   local data
   if staticdata ~= "" and staticdata ~= nil then
      data = minetest.deserialize(staticdata) or {}
   end
   self.def = data
   if self.def.owner_name == nil or self.def.vel == nil or self.def.pos == nil then
      -- entity is corrupt.
      print(dump(self.def))
      minetest.log("warning", "A covid19:ExplosiveProjectile instance is corrupt, removing.")
      self.object:remove()
      return
   end
   
   self.object:set_velocity(self.def.vel)
   self.object:set_acceleration({x=0,y=-get_gravity(),z=0})
end


-- Owner is a reference to the player who owns the projectile
function LaunchExplosiveProjectile(def)
   local staticdata = minetest.serialize(def)
   minetest.add_entity(def.pos, "covid19:ExplosiveProjectile", staticdata)
end


minetest.register_entity("covid19:ExplosiveProjectile", ExplosiveProjectile)


--[[ 
def:

]]--
function register_vaccine(name, def)
   minetest.register_craftitem(name, {
				  description = def.description,
				  inventory_image = def.inventory_image,
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

				     LaunchExplosiveProjectile({
					   pos=pos,
					   vel=vel,
					   owner_name=user:get_player_name(),
					   blast_strength=def.blast_strength,
					   blast_radius=def.blast_radius
				     })
				     
				     if minetest.is_creative_enabled(player_name) then
					return itemstack
				     end
				     
				     itemstack:take_item()
				     return itemstack
				  end
   })
end


register_vaccine("covid19:vaccine_jj", {
		    description = "Vaccine (J&J)",
		    inventory_image = "covid19_vaccine_jj.png",
		    blast_radius = 5,
		    blast_strength = 1250
})
register_vaccine("covid19:vaccine_pfizer", {
		    description = "Vaccine (Pfizer)",
		    inventory_image = "covid19_vaccine_pfizer.png",
		    blast_radius = 1.75,
		    blast_strength = 100000
})
