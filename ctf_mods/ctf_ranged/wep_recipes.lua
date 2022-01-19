-- ctf_ranged/wep_recipes.lua


--[[
   basic_materials:gear_steel

   Steel gear + copper ingot = tier 1 pistol
   Steel gear + silver ingot = tier 1 rifle 
   Steel gear + steel ingot = tier 1 SMG 
   Steel gear + gold ingot = tier 1 shotgun 
   Steel gear + brass ingot = tier 1 DMR 
   Steel gear + mese frag = tier 1 HMG 

   [Tier 1 Part] + [resource block] = Tier 2 part

   [Tier 2 part] + [Crystal, Gemstones gem, nether ingot] = Tier 3 Part

]]--

minetest.register_craftitem("ctf_ranged:gunpart1", {
			       description = "Tier 1 gun part",
			       inventory_image = "rangedweapons_gunpart1.png"
})
minetest.register_craftitem("ctf_ranged:gunpart2", {
			       description = "Tier 2 gun part",
			       inventory_image = "rangedweapons_gunpart2.png"
})
minetest.register_craftitem("ctf_ranged:gunpart3", {
			       description = "Tier 3 gun part",
			       inventory_image = "rangedweapons_gunpart3.png"
})

if(minetest.get_modpath("mobs_mc")) ~= nil then
   minetest.register_craft({
	 output = "ctf_ranged:ammo",
	 type = "shapeless",
	 recipe = {
	    "default:copper_ingot",
	    "mobs_mc:slimeball"
	 }
   })
else
   minetest.register_craft({
	 output = "ctf_ranged:ammo",
	 type = "shapeless",
	 recipe = {
	    "default:copper_ingot",
	    "default:gravel"
	 }
   })
end

minetest.register_craft({
      output = "ctf_ranged:gunpart1",
      type = "shapeless",
      recipe = {
	 "basic_materials:gear_steel",
	 "default:steelblock"
      }
})
minetest.register_craft({
      output = "ctf_ranged:gunpart2",
      recipe = {
	 {"", "", ""},
	 {"default:goldblock", "ctf_ranged:gunpart1", "default:goldblock"},
	 {"", "", ""},
      }
})
minetest.register_craft({
      output = "ctf_ranged:gunpart3",
      recipe = {
	 {"", "", ""},
	 {"default:diamondblock", "ctf_ranged:gunpart2", "default:diamondblock"},
	 {"", "", ""},
      }
})




