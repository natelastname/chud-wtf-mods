mobs_mc = {}

mobs_mc.override = {}

mobs_mc.override.spawn_height = {
	nether_min = nether.DEPTH_FLOOR,
	nether_max = nether.DEPTH_CEILING
}

mobs_mc.override.items = {
   arrow = "ctf_ranged:ammo",
   bow="ctf_ranged:makarov",
   music_discs = {"ctf_ranged:deagle_gold"}
}

minetest.log("action", "Nether boundaries:"
		.. " nether.DEPTH_CEILING=" .. tostring(nether.DEPTH_CEILING)
		.. ", nether.DEPTH_FLOOR=" ..  tostring(nether.DEPTH_FLOOR))
