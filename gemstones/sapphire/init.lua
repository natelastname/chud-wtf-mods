-----------------
-- Ores/blocks --
-----------------

minetest.register_node("sapphire:sapphire_block", {
    description = ("Sapphire Block"),
    tiles = {"sapphire_block.png"},
    is_ground_content = true,
    groups = {cracky = 3},
})

minetest.register_node("sapphire:sapphire_ore", {
	description = ("Sapphire Ore"),
	tiles = {"default_stone.png^sapphire_ore.png"},
	is_ground_content = true,
	groups = {cracky = 3},
	drop = "sapphire:sapphire",
})

minetest.register_craftitem("sapphire:sapphire", {
	description = ("Sapphire"),
	inventory_image = "sapphire.png",
})

------------
-- Tools --
------------

minetest.register_tool("sapphire:sapphire_sword", {
	description = "Sapphire Sword",
	inventory_image = "sapphire_sword.png",
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

minetest.register_tool("sapphire:sapphire_pickaxe", {
	description = "Sapphire Pickaxe",
	inventory_image = "sapphire_pickaxe.png",
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

minetest.register_tool("sapphire:sapphire_axe", {
	description = "Sapphire Axe",
	inventory_image = "sapphire_axe.png",
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

minetest.register_tool("sapphire:sapphire_shovel", {
	description = "Sapphire Shovel",
	inventory_image = "sapphire_shovel.png",
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
	          ore            = "sapphire:sapphire_ore",
	          wherein        = "default:stone",
	          clust_scarcity = 15 * 15 * 15,
	          clust_num_ores = 4,
	          clust_size     = 3,
	          y_max          = -256,
	          y_min          = -31000,
	   })
	   
	  minetest.register_ore({
		      ore_type       = "scatter",
		      ore            = "sapphire:sapphire_ore",
		      wherein        = "default:stone",
		      clust_scarcity = 17 * 17 * 17,
		      clust_num_ores = 4,
		      clust_size     = 3,
		      y_max          = -128,
		      y_min          = -255,
	   })

	  minetest.register_ore({
		       ore_type       = "scatter",
		       ore            = "sapphire:sapphire_ore",
		       wherein        = "default:stone",
		       clust_scarcity = 15 * 15 * 15,
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
	output = "sapphire:sapphire_sword",
	recipe = {
		{"sapphire:sapphire"},
		{"sapphire:sapphire"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "sapphire:sapphire_pickaxe",
	recipe = {
		{"sapphire:sapphire", "sapphire:sapphire", "sapphire:sapphire"},
		{"", "group:stick", ""},
		{"", "group:stick", ""},
	}
})

minetest.register_craft({
	output = "sapphire:sapphire_shovel",
	recipe = {
		{"sapphire:sapphirey"},
		{"group:stick"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "sapphire:sapphire_axe",
	recipe = {
		{"sapphire:sapphire", "sapphire:sapphire"},
		{"sapphire:sapphire", "group:stick"},
		{"", "group:stick"},
	}
})

minetest.register_craft({
	output = "sapphire:sapphire_block",
	recipe = {
		{"sapphire:sapphire", "sapphire:sapphire", "sapphire:sapphire"},
		{"sapphire:sapphire", "sapphire:sapphire", "sapphire:sapphire"},
		{"sapphire:sapphire", "sapphire:sapphire", "sapphire:sapphire"},
	}
})

minetest.register_craft({
	output = "sapphire:sapphire",
	recipe = {
        {"sapphire:sapphire_block"}
	}
})

-- Armor

minetest.register_craft({
	output = "sapphire:helmet_sapphire",
	recipe = {
		{"sapphire:sapphire", "sapphire:sapphire", "sapphire:sapphire"},
		{"sapphire:sapphire", "", "sapphire:sapphire"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "sapphire:chestplate_sapphire",
	recipe = {
		{"sapphire:sapphire", "", "sapphire:sapphire"},
		{"sapphire:sapphire", "sapphire:sapphire", "sapphire:sapphire"},
		{"sapphire:sapphire", "sapphire:sapphire", "sapphire:sapphire"},
	}
})

minetest.register_craft({
	output = "ruby:leggings_ruby",
	recipe = {
		{"sapphire:sapphire", "sapphire:sapphire", "sapphire:sapphire"},
		{"sapphire:sapphire", "", "sapphire:sapphire"},
		{"sapphire:sapphire", "", "sapphire:sapphire"},
	}
})

minetest.register_craft({
	output = "sapphire:boots_sapphire",
	recipe = {
		{"sapphire:sapphire", "", "sapphire:sapphire"},
		{"sapphire:sapphire", "", "sapphire:sapphire"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "sapphire:shield_sapphire",
	recipe = {
		{"sapphire:sapphire", "", "sapphire:sapphire"},
		{"sapphire:sapphire", "sapphire:sapphire", "sapphire:sapphire"},
		{"", "sapphire:sapphire", ""},
	}
})

-----------------------
-- 3D Armor support --
-----------------------

if minetest.get_modpath("3d_armor") then
	armor:register_armor("sapphire:helmet_sapphire", {
		description = ("Sapphire Helmet"),
		inventory_image = "sapphire_helmet_inv.png",
		groups = {armor_head=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=1, level=6},
    })

	armor:register_armor("sapphire:leggings_sapphire", {
		description = ("Sapphire Leggings"),
		inventory_image = "sapphire_leggings_inv.png",
		groups = {armor_legs=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=30},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

	armor:register_armor("sapphire:chestplate_sapphire", {
		description = ("Sapphire Chestplate"),
		inventory_image = "sapphire_chestplate_inv.png",
		groups = {armor_torso=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=30},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

		armor:register_armor("sapphire:boots_sapphire", {
		description = ("Sapphire Boots"),
		inventory_image = "sapphire_boots_inv.png",
		groups = {armor_feet=1, armor_heal=16, armor_use=70, physics_jump=0.5},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

		armor:register_armor("sapphire:shield_sapphire", {
			description = ("Sapphire Shield"),
			inventory_image = "sapphire_shield_inv.png",
			groups = {armor_shield=1, armor_heal=12, armor_use=70},
			armor_groups = {fleshy=10},
			damage_groups = {cracky=2, snappy=1, level=6},
	})

end
