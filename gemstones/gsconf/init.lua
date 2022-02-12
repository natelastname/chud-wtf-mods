-- gsconf/init.lua


-- Average distances between ores
local d_sapphire = 40
local d_amethyst = 40
local d_emerald = 40
local d_ruby = 40

-- groups: can specify physics_speed multiplier, and a jump height multiplier
local emerald_armor = {
   groups_helmet = {armor_head=1, armor_heal=16, armor_use=70},
   groups_chest = {armor_torso=1, armor_heal=16, armor_use=70},
   groups_leggings = {armor_legs=1, armor_heal=16, armor_use=70},
   groups_boots = {armor_feet=1, armor_heal=16, armor_use=70},
   groups_shield = {armor_shield=1, armor_heal=12, armor_use=70},
   armor_groups_helmet = {fleshy=10},
   armor_groups_chest = {fleshy=30},
   armor_groups_leggings = {fleshy=30},
   armor_groups_boots = {fleshy=10},
   armor_groups_shield = {fleshy=10},
   dmg_groups_helmet = {cracky=2, snappy=1, level=6},
   dmg_groups_chest = {cracky=2, snappy=1, level=6},
   dmg_groups_leggings = {cracky=2, snappy=1, level=6},
   dmg_groups_boots = {cracky=2, snappy=1, level=6},
   dmg_groups_shield = {cracky=2, snappy=1, level=6}
}

local ruby_armor = {
   groups_helmet = {armor_head=1, armor_heal=16, armor_use=70},
   groups_chest = {armor_torso=1, armor_heal=16, armor_use=70},
   groups_leggings = {armor_legs=1, armor_heal=16, armor_use=70},
   groups_boots = {armor_feet=1, armor_heal=16, armor_use=70},
   groups_shield = {armor_shield=1, armor_heal=12, armor_use=70},
   armor_groups_helmet = {fleshy=10},
   armor_groups_chest = {fleshy=30},
   armor_groups_leggings = {fleshy=30},
   armor_groups_boots = {fleshy=10},
   armor_groups_shield = {fleshy=10},
   dmg_groups_helmet = {cracky=2, snappy=1, level=6},
   dmg_groups_chest = {cracky=2, snappy=1, level=6},
   dmg_groups_leggings = {cracky=2, snappy=1, level=6},
   dmg_groups_boots = {cracky=2, snappy=1, level=6},
   dmg_groups_shield = {cracky=2, snappy=1, level=6}
}

local sapphire_armor = {
   groups_helmet = {armor_head=1, armor_heal=16, armor_use=70},
   groups_chest = {armor_torso=1, armor_heal=16, armor_use=70},
   groups_leggings = {armor_legs=1, armor_heal=16, armor_use=70},
   groups_boots = {armor_feet=1, armor_heal=16, armor_use=70},
   groups_shield = {armor_shield=1, armor_heal=12, armor_use=70},
   armor_groups_helmet = {fleshy=10},
   armor_groups_chest = {fleshy=30},
   armor_groups_leggings = {fleshy=30},
   armor_groups_boots = {fleshy=10},
   armor_groups_shield = {fleshy=10},
   dmg_groups_helmet = {cracky=2, snappy=1, level=6},
   dmg_groups_chest = {cracky=2, snappy=1, level=6},
   dmg_groups_leggings = {cracky=2, snappy=1, level=6},
   dmg_groups_boots = {cracky=2, snappy=1, level=6},
   dmg_groups_shield = {cracky=2, snappy=1, level=6}
}

local amethyst_armor = {
   groups_helmet = {armor_head=1, armor_heal=16, armor_use=70},
   groups_chest = {armor_torso=1, armor_heal=16, armor_use=70},
   groups_leggings = {armor_legs=1, armor_heal=16, armor_use=70},
   groups_boots = {armor_feet=1, armor_heal=16, armor_use=70},
   groups_shield = {armor_shield=1, armor_heal=12, armor_use=70},
   armor_groups_helmet = {fleshy=10},
   armor_groups_chest = {fleshy=30},
   armor_groups_leggings = {fleshy=30},
   armor_groups_boots = {fleshy=10},
   armor_groups_shield = {fleshy=10},
   dmg_groups_helmet = {cracky=2, snappy=1, level=6},
   dmg_groups_chest = {cracky=2, snappy=1, level=6},
   dmg_groups_leggings = {cracky=2, snappy=1, level=6},
   dmg_groups_boots = {cracky=2, snappy=1, level=6},
   dmg_groups_shield = {cracky=2, snappy=1, level=6}
}


gsconf = { 
   scarcity_sapphire_ore = d_sapphire*d_sapphire*d_sapphire,
   scarcity_ruby_ore= d_ruby*d_ruby*d_ruby,
   scarcity_amethyst_ore = d_amethyst*d_amethyst*d_amethyst,
   scarcity_emerald_ore = d_emerald*d_emerald*d_emerald,
   ruby_armor=ruby_armor,
   sapphire_armor=sapphire_armor,
   amethyst_armor=amethyst_armor,
   emerald_armor=emerald_armor
}
