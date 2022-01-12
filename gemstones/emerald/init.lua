-----------------
-- Ores/blocks --
-----------------

minetest.register_node("emerald:emerald_block", {
    description = ("Emerald Block"),
    tiles = {"emerald_block.png"},
    is_ground_content = true,
    groups = {cracky = 3},
})

minetest.register_node("emerald:emerald_ore", {
	description = ("Emerald Ore"),
	tiles = {"default_stone.png^emerald_ore.png"},
	is_ground_content = true,
	groups = {cracky = 3},
	drop = "emerald:emerald",
})

minetest.register_craftitem("emerald:emerald", {
	description = ("Emerald"),
	inventory_image = "emerald.png",
})

------------
-- Tools --
------------

minetest.register_tool("emerald:emerald_sword", {
	description = "Emerald Sword",
	inventory_image = "emerald_sword.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
		},
		damage_groups = {fleshy=8},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1}
})

minetest.register_tool("emerald:emerald_pickaxe", {
	description = "Emerald Pickaxe",
	inventory_image = "emerald_pickaxe.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level=3,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=80, maxlevel=3},
		},
		damage_groups = {fleshy=5},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})

minetest.register_tool("emerald:emerald_axe", {
	description = "Emerald Axe",
	inventory_image = "emerald_axe.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=80, maxlevel=3},
		},
		damage_groups = {fleshy=7},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1}
})

minetest.register_tool("emerald:emerald_shovel", {
	description = "Emerald Shovel",
	inventory_image = "emerald_shovel.png",
	tool_capabilities = {
         full_punch_interval = 0.5,
	     max_drop_level=1,
		 groupcaps={
			 crumbly = {times={[1]=1.10, [2]=0.50, [3]=0.30}, uses=80, maxlevel=3},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1}
})

-----------------
-- Mapgen --
-----------------

-- Amethyst Ore

minetest.register_ore({
      ore_type       = "scatter",
      ore            = "emerald:emerald_ore",
      wherein        = "default:stone",
      clust_scarcity = gsconf.scarcity_emerald_ore,
      clust_num_ores = 4,
      clust_size     = 3,
      y_max          = -256,
      y_min          = -31000,
})

-------------
-- Crafts --
-------------

-- Tools

minetest.register_craft({
	output = "emerald:emerald_sword",
	recipe = {
		{"emerald:emerald"},
		{"emerald:emerald"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "emerald:emerald_pickaxe",
	recipe = {
		{"emerald:emerald", "emerald:emerald", "emerald:emerald"},
		{"", "group:stick", ""},
		{"", "group:stick", ""},
	}
})

minetest.register_craft({
	output = "emerald:emerald_shovel",
	recipe = {
		{"emerald:emerald"},
		{"group:stick"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "emerald:emerald_axe",
	recipe = {
		{"emerald:emerald", "emerald:emerald"},
		{"emerald:emerald", "group:stick"},
		{"", "group:stick"},
	}
})

minetest.register_craft({
	output = "emerald:emerald_block",
	recipe = {
		{"emerald:emerald", "emerald:emerald", "emerald:emerald"},
		{"emerald:emerald", "emerald:emerald", "emerald:emerald"},
		{"emerald:emerald", "emerald:emerald", "emerald:emerald"},
	}
})

minetest.register_craft({
	output = "emerald:emerald 9",
	recipe = {
		{"emerald:emerald_block"},
	}
})

-- Armor

minetest.register_craft({
	output = "emerald:helmet_emerald",
	recipe = {
		{"emerald:emerald", "emerald:emerald", "emerald:emerald"},
		{"emerald:emerald", "", "emerald:emerald"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "emerald:chestplate_emerald",
	recipe = {
		{"emerald:emerald", "", "emerald:emerald"},
		{"emerald:emerald", "emerald:emerald", "emerald:emerald"},
		{"emerald:emerald", "emerald:emerald", "emerald:emerald"},
	}
})

minetest.register_craft({
	output = "emerald:leggings_emerald",
	recipe = {
		{"emerald:emerald", "emerald:emerald", "emerald:emerald"},
		{"emerald:emerald", "", "emerald:emerald"},
		{"emerald:emerald", "", "emerald:emerald"},
	}
})

minetest.register_craft({
	output = "emerald:boots_emerald",
	recipe = {
		{"emerald:emerald", "", "emerald:emerald"},
		{"emerald:emerald", "", "emerald:emerald"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "emerald:shield_emerald",
	recipe = {
		{"emerald:emerald", "", "emerald:emerald"},
		{"emerald:emerald", "emerald:emerald", "emerald:emerald"},
		{"", "emerald:emerald", ""},
	}
})

-----------------------
-- 3D Armor support --
-----------------------

if minetest.get_modpath("3d_armor") then
	armor:register_armor("emerald:helmet_emerald", {
		description = ("Emerald Helmet"),
		inventory_image = "emerald_helmet_inv.png",
		groups = {armor_head=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=1, level=6},
    })

	armor:register_armor("emerald:leggings_emerald", {
		description = ("Emerald Leggings"),
		inventory_image = "emerald_leggings_inv.png",
		groups = {armor_legs=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=30},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

	armor:register_armor("emerald:chestplate_emerald", {
		description = ("Emerald Chestplate"),
		inventory_image = "emerald_chestplate_inv.png",
		groups = {armor_torso=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=30},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

		armor:register_armor("emerald:boots_emerald", {
		description = ("Emerald Boots"),
		inventory_image = "emerald_boots_inv.png",
		groups = {armor_feet=1, armor_heal=16, armor_use=70, physics_speed=1, physics_jump=1},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

		armor:register_armor("emerald:shield_emerald", {
			description = ("Emerald Shield"),
			inventory_image = "emerald_shield_inv.png",
			groups = {armor_shield=1, armor_heal=12, armor_use=70},
			armor_groups = {fleshy=10},
			damage_groups = {cracky=2, snappy=1, level=6},
	})

end
