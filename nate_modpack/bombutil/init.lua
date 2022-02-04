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



local resistances = {
   --["default:obsidianbrick"] = 500,
   ["basic_materials:brass_block"] = 1500,
   ["doors:door_steel_a"] = 1500,
   ["doors:door_steel_c"] = 1500,
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

function set_blast_resistance(name, resistance)
   if not minetest.registered_nodes[name].groups then
      minetest.registered_nodes[name].groups = {}
   end
   minetest.registered_nodes[name].groups.blast_resistance = resistance
   print(dump(minetest.registered_nodes[name]))
end


local function print_blast_resistances()
   local items = {}

   for name, def in pairs(minetest.registered_nodes) do
      local blast_res = explosions.get_blastres(def.name, def)

      if blast_res > 400 then
	 table.insert(items, {name=name, br=blast_res})
      end

      --local capabilities = minetest.registered_items["default:pick_steel"].tool_capabilities
      --local params = minetest.get_dig_params(def.groups, capabilities)
      --print(dump(params))
   end
   -- First sort by blast resistance, then sort by name
   table.sort(items, function(a,b)
		 if a.br == b.br then
		    if a.name > b.name then
		       return true
		    end
		 end
		 if a.br < b.br then
		    return true
		 end
   end)
   for i, v in pairs(items) do
      --print(v.name .."," ..tostring(v.br))
   end
   
end

minetest.register_on_mods_loaded(function()
      for k in pairs(resistances) do
	 explosions.set_blastres(k, resistances[k])
      end

      print_blast_resistances()
end)


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

-- A wrapped around the raycasted explosions mod that adds some particles and sound.
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
