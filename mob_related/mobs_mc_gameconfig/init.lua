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

print("mobs_mc_gameconfig:")
print(nether.DEPTH_CEILING)
print(nether.DEPTH_FLOOR)
