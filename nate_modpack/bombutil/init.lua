-- bombutil/init.lua

-- A simplified/optimized version of the explosions from the default tnt mod.
-- This is intended as a base for multiplayer mods that require more control
-- over explosions.
-- Features:
-- - Blocks have simplified explosion resistances
-- - Explosions cause less items to drop
-- - Explosions do not cause fire 
-- - Explosions can be triggered programatically with adjustable properties
-- - Particles are simplified
bombutil = {}


loss_probs = {}
function set_blast_resistance(name, resistance)
   if not minetest.registered_nodes[name].groups then
      minetest.registered_nodes[name].groups = {}
   end
   minetest.registered_nodes[name].groups.blast_resistance = resistance
   print(dump(minetest.registered_nodes[name]))
end


local resistances = {
   ["default:obsidianbrick"] = 500,
   ["basic_materials:brass_block"] = 1500,
   ["default:copperblock"] = 1500,
   ["default:bronzeblock"] = 1500,
   ["default:tinblock"] = 1500,
   ["default:steelblock"] = 1500,
   ["moreores:silver_block"] = 1500,
   ["ethereal:crystal_block"] = 1500,
   ["default:mese"] = 1500, 
   ["default:goldblock"] = 1500, 
   ["moreores:mithril_block"] = 1500, 
   ["ruby:ruby_block"] =1500, 
   ["emerald:emerald_block"] = 1500, 
   ["sapphire:sapphire_block"] = 1500, 
   ["amethyst:amethyst_block"] = 1500, 
   ["default:diamondblock"] = 1500
}


minetest.after(5, function()
		  for name, def in pairs(minetest.registered_nodes) do
		     local blast_res = explosions.get_blastres(def.name, def)
		     if blast_res > 400 then
			print(name .. ": " .. tostring(blast_res))
		     end
		     local capabilities = minetest.registered_items["default:pick_steel"].tool_capabilities
		     local params = minetest.get_dig_params(def.groups, capabilities)
		     --print(dump(params))
		  end
end)


-- Fill a list with data for content IDs, after all nodes are registered
local cid_data = {}
minetest.register_on_mods_loaded(function()

      for k in pairs(resistances) do
	 explosions.set_blastres(k, resistances[k])
      end

      print("Computing blast resistances:")
      for name, def in pairs(minetest.registered_nodes) do
	 local blast_res = explosions.get_blastres(def.name, def)
	 if blast_res > 400 then
	    print(name .. ": " .. tostring(blast_res))
	 end
	 local capabilities = minetest.registered_items["default:pick_steel"].tool_capabilities
	 local params = minetest.get_dig_params(def.groups, capabilities)
	 --print(dump(params))


	 local p = 1
	 if loss_probs[name] ~= nil then
	    p = 1/loss_probs[name]
	 end
	 cid_data[minetest.get_content_id(name)] = {
	    name = name,
	    drops = def.drops,
	    loss_prob = p,
	    flammable = def.groups.flammable,
	    on_blast = def.on_blast,
	 }
      end
end)

-- Called on each block in the blast radius
local function destroy(npos, cid, c_air, on_blast_queue,
		       ignore_protection, ignore_on_blast, owner)
   if not ignore_protection and minetest.is_protected(npos, owner) then
      return cid
   end

   local def = cid_data[cid]

   if not def then
      return c_air
   elseif not ignore_on_blast and def.on_blast then
      -- If the block has an on_blast function, add that function to on_blast_queue
      on_blast_queue[#on_blast_queue + 1] = {
	 pos = vector.new(npos),
	 on_blast = def.on_blast
      }
      return cid
   else
      return c_air
   end
end

local function calc_velocity(pos1, pos2, old_vel, power)
   -- Avoid errors caused by a vector of zero length
   if vector.equals(pos1, pos2) then
      return old_vel
   end

   local vel = vector.direction(pos1, pos2)
   vel = vector.normalize(vel)
   vel = vector.multiply(vel, power)

   -- Divide by distance
   local dist = vector.distance(pos1, pos2)
   dist = math.max(dist, 1)
   vel = vector.divide(vel, dist)

   -- Add old velocity
   vel = vector.add(vel, old_vel)

   -- randomize it a bit
   vel = vector.add(vel, {
		       x = math.random() - 0.5,
		       y = math.random() - 0.5,
		       z = math.random() - 0.5,
   })

   -- Limit to terminal velocity
   dist = vector.length(vel)
   if dist > 250 then
      vel = vector.divide(vel, dist / 250)
   end
   return vel
end

local function add_effects(pos, radius)
   minetest.add_particle({
	 pos = pos,
	 velocity = vector.new(),
	 acceleration = vector.new(),
	 expirationtime = 0.4,
	 size = radius * 10,
	 collisiondetection = false,
	 vertical = false,
	 texture = "tnt_boom.png",
	 glow = 15,
   })
   local v = radius * 2
   minetest.add_particlespawner({
	 amount = 64,
	 time = 0.5,
	 minpos = vector.subtract(pos, radius / 2),
	 maxpos = vector.add(pos, radius / 2),
	 minvel = vector.new({x = -v, y = -v, z = -v}),
	 maxvel = {x = v, y = v, z = v},
	 minacc = vector.new(),
	 maxacc = vector.new(),
	 minexptime = 1,
	 maxexptime = 2.5,
	 minsize = radius * 3,
	 maxsize = radius * 5,
	 texture = "tnt_smoke.png",
   })

end

local function tnt_explode(pos, radius, ignore_protection,
			   ignore_on_blast, owner, explode_center)
   -- scan for adjacent TNT nodes first, and enlarge the explosion
   -- At this point, the default tnt mod does the following, presumably as an optimization:
   -- 1. iterate over the 5x5x5 cube centered at the explosion
   -- 2. Delete all tnt related blocks in this area
   -- 3. Make the radius of the explosion bigger to compensate (using a cube root law)

   -- We skip this step.

   
   -- perform the explosion
   pos = vector.round(pos)
   local vm = VoxelManip()
   local pr = PseudoRandom(os.time())
   local c_air = minetest.get_content_id("air")

   local p1 = vector.subtract(pos, radius)
   local p2 = vector.add(pos, radius)
   local minp, maxp = vm:read_from_map(p1, p2)
   local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
   local data = vm:get_data()

   local on_blast_queue = {}

   for z = -radius, radius do
      for y = -radius, radius do
	 local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
	 for x = -radius, radius do	    
	    local r = vector.length(vector.new(x, y, z))
	    --if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
	    local cid = data[vi]
	    if pr:next(1,100)/100 <= cid_data[cid].loss_prob then
	       local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
	       if cid ~= c_air then
		  data[vi] = destroy(p, cid, c_air, on_blast_queue,
				     ignore_protection, ignore_on_blast, owner)
	       end
	    end
	    vi = vi + 1
	 end
      end
   end

   vm:set_data(data)
   vm:write_to_map()
   vm:update_map()
   vm:update_liquids()

   -- call check_single_for_falling for everything within 1.5x blast radius
   for y = -radius * 1.5, radius * 1.5 do
      for z = -radius * 1.5, radius * 1.5 do
	 for x = -radius * 1.5, radius * 1.5 do
	    local rad = {x = x, y = y, z = z}
	    local s = vector.add(pos, rad)
	    local r = vector.length(rad)
	    if r / radius < 1.4 then
	       minetest.check_single_for_falling(s)
	    end
	 end
      end
   end
   -- Skipping this block of code not because I have found that some mods (etherium) 
   -- implement on_blast innapropriately
   for _, queued_data in pairs(on_blast_queue) do
      local dist = math.max(1, vector.distance(queued_data.pos, pos))
      local intensity = (radius * radius) / (dist * dist)
      -- This is problematic
      local node_drops = queued_data.on_blast(queued_data.pos, intensity)
   end

   return radius
end

-- Do damage to entities
local function entity_physics(pos, radius, ignore_on_blast_ents)
   local objs = minetest.get_objects_inside_radius(pos, radius)
   for _, obj in pairs(objs) do
      local obj_pos = obj:get_pos()
      local dist = math.max(1, vector.distance(pos, obj_pos))
      local damage = (4 / dist) * radius
      if obj:is_player() then
	 local dir = vector.normalize(vector.subtract(obj_pos, pos))
	 local moveoff = vector.multiply(dir, 2 / dist * radius)
	 moveoff = vector.multiply(moveoff, 2) 
	 obj:add_velocity(moveoff)
	 -- Don't do this for now because it's abuseable
	 --obj:set_hp(obj:get_hp() - damage)
      elseif not ignore_on_blast_ents then
	 local luaobj = obj:get_luaentity()
	 -- object might have disappeared somehow
	 if luaobj then
	    local do_damage = true
	    local do_knockback = true
	    local entity_drops = {}
	    local objdef = minetest.registered_entities[luaobj.name]

	    if objdef and objdef.on_blast then
	       do_damage, do_knockback, entity_drops = objdef.on_blast(luaobj, damage)
	    end

	    if do_knockback then
	       local obj_vel = obj:get_velocity()
	       obj:set_velocity(calc_velocity(pos, obj_pos,
					      obj_vel, radius * 10))
	    end
	    if do_damage then
	       if not obj:get_armor_groups().immortal then
		  obj:punch(obj, 1.0, {
			       full_punch_interval = 1.0,
			       damage_groups = {fleshy = damage},
				      }, nil)
	       end
	    end
	 end
      end
   end
end


-- Eventually this should be modified to use the raycasted explosions mod for the
-- actual bomb logic instead of code derived from default:tnt. So, we will only
-- use the sound/particles from default:tnt
function bombutil.boom(pos, owner, def)
   def = def or {}
   def.radius = def.radius or 1
   def.damage_radius = def.damage_radius or def.radius * 2
   if def.radius == 0 then
      def.destroy_blocks = false
   end
   def.destroy_blocks = def.destroy_blocks or true 
   
   -- Owner must be a player
   if owner == nil then
      minetest.log("action", "Bombutil explosion failed: owner was nil. (Pos:"
		      .. minetest.pos_to_string(pos) .. " Radius " .. def.radius)
      return
   end
   local sound = def.sound or "tnt_explode"
   minetest.sound_play(sound, {pos = pos, gain = 2.5,
			       max_hear_distance = math.min(def.radius * 20, 128)}, true)
   
   add_effects(pos, def.radius)
end
