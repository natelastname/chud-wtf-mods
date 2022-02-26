

-- Bare minimum needed to get dungeons to work
minetest.register_alias("mcl_core:cobble", "default:cobble")
minetest.register_alias("mcl_core:mossycobble", "default:mossycobble")
minetest.register_alias("mcl_chests:chest", "default:chest")
minetest.register_alias("mcl_core:apple_gold", "ethereal:golden_apple")
minetest.register_alias("mcl_core:apple_gold_enchanted", "ethereal:golden_apple")
minetest.register_alias("mcl_books:book", "default:book")
minetest.register_alias("mcl_farming:wheat_item", "mobs:saddle")
minetest.register_alias("mcl_farming:bread", "mobs:saddle")
minetest.register_alias("mcl_core:iron_ingot", "default:steel_ingot")
minetest.register_alias("mcl_core:gold_ingot", "default:gold_ingot")
minetest.register_alias("mcl_farming:beetroot_seeds", "farming:beetroot")
minetest.register_alias("mcl_farming:melon_seeds", "farming:melon_slice")
minetest.register_alias("mcl_farming:pumpkin_seeds", "farming:pumpkin_slice")
minetest.register_alias("mcl_buckets:bucket_empty", "bucket:bucket_empty")
minetest.register_alias("mcl_mobitems:saddle", "mobs:saddle")
minetest.register_alias("mcl_farming:wheat_item", "farming:wheat")
minetest.register_alias("mcl_farming:bread", "farming:bread")
minetest.register_alias("mcl_core:coal_lump", "default:coal_lump")
minetest.register_alias("mesecons:redstone", "default:mese_crystal_fragment")
minetest.register_alias("mcl_mobitems:bone", "mobs_mc:bone")
minetest.register_alias("mcl_mobitems:gunpowder", "tnt:gunpowder")
minetest.register_alias("mcl_mobitems:rotten_flesh", "mobs_mc:rotten_flesh")
minetest.register_alias("mcl_mobitems:string", "farming:string")
minetest.register_alias("mcl_mobitems:birchsapling", "default:birch_sapling")
minetest.register_alias("mcl_mobitems:acaciasapling", "default:acacia_sapling")
minetest.register_alias("mcl_mobs:nametag", "mobs:nametag")
minetest.register_alias("mcl_mobitems:acaciasapling", "default:acacia_sapling")


minetest.register_alias("mcl_mobitems:milk_bucket", "mobs_mc:milk_bucket")
minetest.register_alias("mcl_core:sugar", "farming:sugar")
minetest.register_alias("mcl_throwing:egg", "mobs_mc:egg")
minetest.register_alias("mcl_farming:wheat_item", "farming:wheat")
minetest.register_alias("mcl_core:diamond", "default:diamond")

minetest.register_alias("mcl_core:stone", "default:stone")
minetest.register_alias("mcl_core:bone_block", "bones:bones")
minetest.register_alias("mcl_core:bedrock", "default:obsidianbrick")
minetest.register_alias("mcl_core:stonebrickcracked", "default:stonebrick")
minetest.register_alias("mcl_portals:end_portal_frame", "balloonblocks:pink")
minetest.register_alias("mcl_core:stonebrickmossy", "default:mossycobble")

minetest.register_alias("mcl_core:lava_source", "default:lava_source")
minetest.register_alias("mcl_core:lava_flowing", "default:lava_flowing")
minetest.register_alias("mcl_core:water_source", "default:water_flowing")
minetest.register_alias("mcl_core:water_flowing", "default:water_flowing")

minetest.register_alias("mcl_core:stonebrick", "default:stonebrick")
minetest.register_alias("mcl_stairs:stair_stonebrick", "stairs:stair_stonebrick")
minetest.register_alias("mcl_stairs:stair_stonebrick_outer", "stairs:stair_outer_stonebrick")

minetest.register_alias("mcl_villages:stonebrickcarved", "default:stonebrick")

minetest.register_alias("mcl_monster_eggs:monster_egg_stonebrick", "mobs_mc:monster_egg_stonebrick")
minetest.register_alias("mcl_monster_eggs:monster_egg_stonebrickcracked", "mobs_mc:monster_egg_stonebrick")
minetest.register_alias("mcl_monster_eggs:monster_egg_stonebrickmossy", "mobs_mc:monster_egg_stonebrick")
-- sample grep command to extract item names from the source of mineclone:
-- grep -ohr \"mcl_core:[a-Z][a-Z]*\" | uniq
