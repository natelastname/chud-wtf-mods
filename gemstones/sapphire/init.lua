-----------------
-- Ores/blocks --
-----------------

minetest.register_node("gs_sapphire:sapphire_block", {
    description = ("Sapphire Block"),
    tiles = {"gs_sapphire_block.png"},
    is_ground_content = true,
    groups = {cracky = 3},
})

minetest.register_node("gs_sapphire:sapphire_ore", {
	description = ("Sapphire Ore"),
	tiles = {"default_stone.png^gs_sapphire_ore.png"},
	is_ground_content = true,
	groups = {cracky = 3},
	drop = "gs_sapphire:sapphire",
})

minetest.register_craftitem("gs_sapphire:sapphire", {
	description = ("Sapphire"),
	inventory_image = "gs_sapphire.png",
})

------------
-- Tools --
------------

minetest.register_tool("gs_sapphire:sapphire_sword", {
	description = "Sapphire Sword",
	inventory_image = "gs_sapphire_sword.png",
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

minetest.register_tool("gs_sapphire:sapphire_pickaxe", {
	description = "Sapphire Pickaxe",
	inventory_image = "gs_sapphire_pickaxe.png",
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

minetest.register_tool("gs_sapphire:sapphire_axe", {
	description = "Sapphire Axe",
	inventory_image = "gs_sapphire_axe.png",
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

minetest.register_tool("gs_sapphire:sapphire_shovel", {
	description = "Sapphire Shovel",
	inventory_image = "gs_sapphire_shovel.png",
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

-- Ruby Ore

      minetest.register_ore({
	          ore_type       = "scatter",
	          ore            = "gs_sapphire:sapphire_ore",
	          wherein        = "default:stone",
	          clust_scarcity = gsconf.scarcity_sapphire_ore,
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
	output = "gs_sapphire:sapphire_sword",
	recipe = {
		{"gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "gs_sapphire:sapphire_pickaxe",
	recipe = {
		{"gs_sapphire:sapphire", "gs_sapphire:sapphire", "gs_sapphire:sapphire"},
		{"", "group:stick", ""},
		{"", "group:stick", ""},
	}
})

minetest.register_craft({
	output = "gs_sapphire:sapphire_shovel",
	recipe = {
		{"gs_sapphire:sapphire"},
		{"group:stick"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "gs_sapphire:sapphire_axe",
	recipe = {
		{"gs_sapphire:sapphire", "gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire", "group:stick"},
		{"", "group:stick"},
	}
})

minetest.register_craft({
	output = "gs_sapphire:sapphire_block",
	recipe = {
		{"gs_sapphire:sapphire", "gs_sapphire:sapphire", "gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire", "gs_sapphire:sapphire", "gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire", "gs_sapphire:sapphire", "gs_sapphire:sapphire"},
	}
})

minetest.register_craft({
	output = "gs_sapphire:sapphire",
	recipe = {
        {"gs_sapphire:sapphire_block"}
	}
})

-- Armor

minetest.register_craft({
	output = "gs_sapphire:helmet_sapphire",
	recipe = {
		{"gs_sapphire:sapphire", "gs_sapphire:sapphire", "gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire", "", "gs_sapphire:sapphire"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "gs_sapphire:chestplate_sapphire",
	recipe = {
		{"gs_sapphire:sapphire", "", "gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire", "gs_sapphire:sapphire", "gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire", "gs_sapphire:sapphire", "gs_sapphire:sapphire"},
	}
})

minetest.register_craft({
	output = "gs_sapphire:leggings_sapphire",
	recipe = {
		{"gs_sapphire:sapphire", "gs_sapphire:sapphire", "gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire", "", "gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire", "", "gs_sapphire:sapphire"},
	}
})

minetest.register_craft({
	output = "gs_sapphire:boots_sapphire",
	recipe = {
		{"gs_sapphire:sapphire", "", "gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire", "", "gs_sapphire:sapphire"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "gs_sapphire:shield_sapphire",
	recipe = {
		{"gs_sapphire:sapphire", "", "gs_sapphire:sapphire"},
		{"gs_sapphire:sapphire", "gs_sapphire:sapphire", "gs_sapphire:sapphire"},
		{"", "gs_sapphire:sapphire", ""},
	}
})

-----------------------
-- 3D Armor support --
-----------------------

if minetest.get_modpath("3d_armor") then
	armor:register_armor("gs_sapphire:helmet_sapphire", {
		description = ("Sapphire Helmet"),
		inventory_image = "gs_sapphire_helmet_inv.png",
		groups = {armor_head=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=1, level=6},
    })

	armor:register_armor("gs_sapphire:leggings_sapphire", {
		description = ("Sapphire Leggings"),
		inventory_image = "gs_sapphire_leggings_inv.png",
		groups = {armor_legs=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=30},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

	armor:register_armor("gs_sapphire:chestplate_sapphire", {
		description = ("Sapphire Chestplate"),
		inventory_image = "gs_sapphire_chestplate_inv.png",
		groups = {armor_torso=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=30},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

		armor:register_armor("gs_sapphire:boots_sapphire", {
		description = ("Sapphire Boots"),
		inventory_image = "gs_sapphire_boots_inv.png",
		groups = {armor_feet=1, armor_heal=16, armor_use=70, physics_jump=0.5},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

		armor:register_armor("gs_sapphire:shield_sapphire", {
			description = ("Sapphire Shield"),
			inventory_image = "gs_sapphire_shield_inv.png",
			groups = {armor_shield=1, armor_heal=12, armor_use=70},
			armor_groups = {fleshy=10},
			damage_groups = {cracky=2, snappy=1, level=6},
	})

end
