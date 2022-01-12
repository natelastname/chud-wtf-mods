-----------------
-- Ores/blocks --
-----------------

minetest.register_node("gs_amethyst:amethyst_block", {
    description = ("Amethyst Block"),
	tiles = {"gs_amethyst_block.png"},
    is_ground_content = true,
    groups = {cracky = 3},
})

minetest.register_node("gs_amethyst:amethyst_ore", {
	description = ("Amethyst Ore"),
	tiles = {"default_stone.png^gs_amethyst_ore.png"},
	is_ground_content = true,
	groups = {cracky = 3},
	drop = "gs_amethyst:amethyst_ingot",
})

minetest.register_craftitem("gs_amethyst:amethyst_ingot", {
	description = ("Amethyst Ingot"),
	inventory_image = "gs_amethyst.png",
})

------------
-- Tools --
------------

minetest.register_tool("gs_amethyst:amethyst_sword", {
	description = "Amethyst Sword",
	inventory_image = "gs_amethyst_sword.png",
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

minetest.register_tool("gs_amethyst:amethyst_pickaxe", {
	description = "Amethyst Pickaxe",
	inventory_image = "gs_amethyst_pickaxe.png",
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

minetest.register_tool("gs_amethyst:amethyst_axe", {
	description = "Amethyst Axe",
	inventory_image = "gs_amethyst_axe.png",
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

minetest.register_tool("gs_amethyst:amethyst_shovel", {
	description = "Amethyst Shovel",
	inventory_image = "gs_amethyst_shovel.png",
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
	          ore            = "gs_amethyst:amethyst_ore",
	          wherein        = "default:stone",
	          clust_scarcity = gsconf.scarcity_amethyst_ore,
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
	output = "gs_amethyst:amethyst_sword",
	recipe = {
		{"gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "gs_amethyst:amethyst_pickaxe",
	recipe = {
		{"gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot"},
		{"", "group:stick", ""},
		{"", "group:stick", ""},
	}
})

minetest.register_craft({
	output = "gs_amethyst:amethyst_shovel",
	recipe = {
		{"gs_amethyst:amethyst_ingot"},
		{"group:stick"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "gs_amethyst:amethyst_axe",
	recipe = {
		{"gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot", "group:stick"},
		{"", "group:stick"},
	}
})

minetest.register_craft({
	output = "gs_amethyst:amethyst_block",
	recipe = {
		{"gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot"},
	}
})

minetest.register_craft({
	output = "gs_amethyst:amethyst_ingot 9",
	recipe = {
		{"gs_amethyst:amethyst_block"},
	}
})

-- Armor

minetest.register_craft({
	output = "gs_amethyst:helmet_amethyst",
	recipe = {
		{"gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot", "", "gs_amethyst:amethyst_ingot"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "gs_amethyst:chestplate_amethyst",
	recipe = {
		{"gs_amethyst:amethyst_ingot", "", "gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot"},
	}
})

minetest.register_craft({
	output = "gs_amethyst:leggings_amethyst",
	recipe = {
		{"gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot", "", "gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot", "", "gs_amethyst:amethyst_ingot"},
	}
})

minetest.register_craft({
	output = "gs_amethyst:boots_amethyst",
	recipe = {
		{"gs_amethyst:amethyst_ingot", "", "gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot", "", "gs_amethyst:amethyst_ingot"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "gs_amethyst:shield_amethyst",
	recipe = {
		{"gs_amethyst:amethyst_ingot", "", "gs_amethyst:amethyst_ingot"},
		{"gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot", "gs_amethyst:amethyst_ingot"},
		{"", "gs_amethyst:amethyst_ingot", ""},
	}
})

-----------------------
-- 3D Armor support --
-----------------------

if minetest.get_modpath("3d_armor") then
	armor:register_armor("gs_amethyst:helmet_amethyst", {
		description = ("Amethyst Helmet"),
		inventory_image = "gs_amethyst_helmet_inv.png",
		groups = {armor_head=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=1, level=6},
    })

	armor:register_armor("gs_amethyst:leggings_amethyst", {
		description = ("Amethyst Leggings"),
		inventory_image = "gs_amethyst_leggings_inv.png",
		groups = {armor_legs=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=30},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

	armor:register_armor("gs_amethyst:chestplate_amethyst", {
		description = ("Amethyst Chestplate"),
		inventory_image = "gs_amethyst_chestplates_inv.png",
		groups = {armor_torso=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=30},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

		armor:register_armor("gs_amethyst:boots_amethyst", {
		description = ("Amethyst Boots"),
		inventory_image = "gs_amethyst_boots_inv.png",
		groups = {armor_feet=1, armor_heal=16, armor_use=70, physics_speed=1.5},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

		armor:register_armor("gs_amethyst:shield_amethyst", {
			description = ("Amethyst Shield"),
			inventory_image = "gs_amethyst_shield_inv.png",
			groups = {armor_shield=1, armor_heal=12, armor_use=70},
			armor_groups = {fleshy=10},
			damage_groups = {cracky=2, snappy=1, level=6},
	})

end
