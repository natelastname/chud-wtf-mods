-----------------
-- Ores/blocks --
-----------------

minetest.register_node("ruby:ruby_block", {
    description = ("Ruby Block"),
    tiles = {"ruby_block.png"},
    is_ground_content = true,
    groups = {cracky = 3},
})

minetest.register_node("ruby:ruby_ore", {
	description = ("Ruby Ore"),
	tiles = {"default_stone.png^ruby_ore.png"},
	is_ground_content = true,
	groups = {cracky = 3},
	drop = "ruby:ruby",
})

minetest.register_craftitem("ruby:ruby", {
	description = ("Ruby"),
	inventory_image = "ruby.png",
})

------------
-- Tools --
------------

minetest.register_tool("ruby:ruby_sword", {
	description = "Ruby Sword",
	inventory_image = "ruby_sword.png",
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

minetest.register_tool("ruby:ruby_pickaxe", {
	description = "Ruby Pickaxe",
	inventory_image = "ruby_pickaxe.png",
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

minetest.register_tool("ruby:ruby_axe", {
	description = "Ruby Axe",
	inventory_image = "ruby_axe.png",
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

minetest.register_tool("ruby:ruby_shovel", {
	description = "Ruby Shovel",
	inventory_image = "ruby_shovel.png",
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
	          ore            = "ruby:ruby_ore",
	          wherein        = "default:stone",
	          clust_scarcity = 15 * 15 * 15,
	          clust_num_ores = 4,
	          clust_size     = 3,
	          y_max          = -256,
	          y_min          = -31000,
	   })
	   
	  minetest.register_ore({
		      ore_type       = "scatter",
		      ore            = "ruby:ruby_ore",
		      wherein        = "default:stone",
		      clust_scarcity = 17 * 17 * 17,
		      clust_num_ores = 4,
		      clust_size     = 3,
		      y_max          = -128,
		      y_min          = -255,
	   })

	  minetest.register_ore({
		       ore_type       = "scatter",
		       ore            = "ruby:ruby_ore",
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
	output = "ruby:ruby_sword",
	recipe = {
		{"ruby:ruby"},
		{"ruby:ruby"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "ruby:ruby_pickaxe",
	recipe = {
		{"ruby:ruby", "ruby:ruby", "ruby:ruby"},
		{"", "group:stick", ""},
		{"", "group:stick", ""},
	}
})

minetest.register_craft({
	output = "ruby:ruby_shovel",
	recipe = {
		{"ruby:ruby"},
		{"group:stick"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "ruby:ruby_axe",
	recipe = {
		{"ruby:ruby", "ruby:ruby"},
		{"ruby:ruby", "group:stick"},
		{"", "group:stick"},
	}
})

minetest.register_craft({
	output = "ruby:ruby_block",
	recipe = {
		{"ruby:ruby", "ruby:ruby", "ruby:ruby"},
		{"ruby:ruby", "ruby:ruby", "ruby:ruby"},
		{"ruby:ruby", "ruby:ruby", "ruby:ruby"},
	}
})

minetest.register_craft({
	output = "ruby:ruby",
	recipe = {
        {"ruby:ruby_block"}
	}
})

-- Armor

minetest.register_craft({
	output = "ruby:helmet_ruby",
	recipe = {
		{"ruby:ruby", "ruby:ruby", "ruby:ruby"},
		{"ruby:ruby", "", "ruby:ruby"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "ruby:chestplate_ruby",
	recipe = {
		{"ruby:ruby", "", "ruby:ruby"},
		{"ruby:ruby", "ruby:ruby", "ruby:ruby"},
		{"ruby:ruby", "ruby:ruby", "ruby:ruby"},
	}
})

minetest.register_craft({
	output = "ruby:leggings_ruby",
	recipe = {
		{"ruby:ruby", "ruby:ruby", "ruby:ruby"},
		{"ruby:ruby", "", "ruby:ruby"},
		{"ruby:ruby", "", "ruby:ruby"},
	}
})

minetest.register_craft({
	output = "ruby:boots_ruby",
	recipe = {
		{"ruby:ruby", "", "ruby:ruby"},
		{"ruby:ruby", "", "ruby:ruby"},
		{"", "", ""},
	}
})

minetest.register_craft({
	output = "ruby:shield_ruby",
	recipe = {
		{"ruby:ruby", "", "ruby:ruby"},
		{"ruby:ruby", "ruby:ruby", "ruby:ruby"},
		{"", "ruby:ruby", ""},
	}
})

-----------------------
-- 3D Armor support --
-----------------------

if minetest.get_modpath("3d_armor") then
	armor:register_armor("ruby:helmet_ruby", {
		description = ("Ruby Helmet"),
		inventory_image = "ruby_helmet_inv.png",
		groups = {armor_head=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=1, level=6},
    })

	armor:register_armor("ruby:leggings_ruby", {
		description = ("Ruby Leggings"),
		inventory_image = "ruby_leggings_inv.png",
		groups = {armor_legs=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=30},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

	armor:register_armor("ruby:chestplate_ruby", {
		description = ("Ruby Chestplate"),
		inventory_image = "ruby_chestplate_inv.png",
		groups = {armor_torso=1, armor_heal=16, armor_use=70},
		armor_groups = {fleshy=30},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

		armor:register_armor("ruby:boots_ruby", {
		description = ("Ruby Boots"),
		inventory_image = "ruby_boots_inv.png",
		groups = {armor_feet=1, armor_heal=16, armor_use=70, physics_jump=0.5},
		armor_groups = {fleshy=10},
		damage_groups = {cracky=2, snappy=1, level=6},
	})

		armor:register_armor("ruby:shield_ruby", {
			description = ("Ruby Shield"),
			inventory_image = "ruby_shield_inv.png",
			groups = {armor_shield=1, armor_heal=12, armor_use=70},
			armor_groups = {fleshy=10},
			damage_groups = {cracky=2, snappy=1, level=6},
	})

end
