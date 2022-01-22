-- Detect creative mod --
local creative_mod = minetest.get_modpath("creative")
-- Cache creative mode setting as fallback if creative mod not present --
local creative_mode_cache = minetest.settings:get_bool("creative_mode")

-- Returns a on_secondary_use function that places the balloon block in the air -- 
local placeColour = function (colour)
	return function(itemstack, user, pointed_thing)
		-- Place node three blocks from the user in the air --
		local pos = user:getpos()
		local dir = user:get_look_dir()
		local balloonPlaceDistanceFromPlayer = 3
		local new_pos = {
			x = pos.x + (dir.x * balloonPlaceDistanceFromPlayer),
			y = pos.y + 1 + (dir.y * balloonPlaceDistanceFromPlayer),
			z = pos.z + (dir.z * balloonPlaceDistanceFromPlayer),
		}
		local getPos = minetest.get_node(new_pos)
		if getPos.name == "air" or
				getPos.name == "default:water_source" or
				getPos.name == "default:water_flowing" or
				getPos.name == "default:river_water_source" or
				getPos.name == "default:river_water_flowing" then
			local name = 'balloonblocks:'..colour
			minetest.set_node(new_pos, {name=name})
			local creative_enabled = (creative_mod and creative.is_enabled_for(user.get_player_name(user))) or creative_mode_cache
			if (not creative_enabled) then
				local stack = ItemStack(name)
				return ItemStack(name .. " " .. itemstack:get_count() - 1)
			end
		end
	end
end

local soundsConfig = function ()
	return {
	  footstep = {name = "balloonblocks_footstep", gain = 0.2},
	  dig = {name = "balloonblocks_footstep", gain = 0.3},
	  dug = {name = "default_dug_hard.1", gain = 0.3},
	  place = {name = "default_place_node_hard", gain = 1.0}
	}
end

-- Holds balloonblock functions and config --
local state = {
	placeRed = placeColour('red'),
	placeYellow = placeColour('yellow'),
	placeGreen = placeColour('green'),
	placeBlue = placeColour('blue'),
	placeBlack = placeColour('black'),
	placeWhite = placeColour('white'),
	placeOrange = placeColour('orange'),
	placePurple = placeColour('purple'),
	placeGrey = placeColour('grey'),
	placePink = placeColour('pink'),
	placeBrown = placeColour('brown'),
	placeGlowRed = placeColour('glowing_red'),
	placeGlowYellow = placeColour('glowing_yellow'),
	placeGlowGreen = placeColour('glowing_green'),
	placeGlowBlue = placeColour('glowing_blue'),
	placeGlowBlack = placeColour('glowing_black'),
	placeGlowWhite = placeColour('glowing_white'),
	placeGlowOrange = placeColour('glowing_orange'),
	placeGlowPurple = placeColour('glowing_purple'),
	placeGlowGrey = placeColour('glowing_grey'),
	placeGlowPink = placeColour('glowing_pink'),
	placeGlowBrown = placeColour('glowing_brown'),
	sounds = soundsConfig(),
	groups = {snappy=3, fall_damage_add_percent = -99, bouncy=70}
}
-- Normal balloonblocks --

minetest.register_node("balloonblocks:red", {
  description = "Red balloon",
  tiles = {"balloonblocks_red.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeRed,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:red',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:red', 'group:leaves'},
		{'dye:red', 'group:leaves', 'dye:red'},
	}
})

minetest.register_node("balloonblocks:yellow", {
	description = "Yellow balloon",
	tiles = {"balloonblocks_yellow.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeYellow,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:yellow',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:yellow', 'group:leaves'},
		{'dye:yellow', 'group:leaves', 'dye:yellow'},
	}
})

minetest.register_node("balloonblocks:green", {
  description = "Green balloon",
  tiles = {"balloonblocks_green.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGreen,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:green',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:green', 'group:leaves'},
		{'dye:green', 'group:leaves', 'dye:green'},
	}
})

minetest.register_node("balloonblocks:blue", {
  description = "Blue balloon",
  tiles = {"balloonblocks_blue.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeBlue,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:blue',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:blue', 'group:leaves'},
		{'dye:blue', 'group:leaves', 'dye:blue'},
	}
})

minetest.register_node("balloonblocks:black", {
  description = "Black balloon",
  tiles = {"balloonblocks_black.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeBlack,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:black',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:black', 'group:leaves'},
		{'dye:black', 'group:leaves', 'dye:black'},
	}
})

minetest.register_node("balloonblocks:white", {
  description = "White balloon",
  tiles = {"balloonblocks_white.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeWhite,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:white',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:white', 'group:leaves'},
		{'dye:white', 'group:leaves', 'dye:white'},
	}
})

minetest.register_node("balloonblocks:orange", {
  description = "Orange balloon",
  tiles = {"balloonblocks_orange.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeOrange,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:orange',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:orange', 'group:leaves'},
		{'dye:orange', 'group:leaves', 'dye:orange'},
	}
})

minetest.register_node("balloonblocks:purple", {
  description = "Purple balloon",
  tiles = {"balloonblocks_purple.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placePurple,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:purple',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:violet', 'group:leaves'},
		{'dye:violet', 'group:leaves', 'dye:violet'},
	}
})

minetest.register_node("balloonblocks:grey", {
  description = "Grey balloon",
  tiles = {"balloonblocks_grey.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGrey,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:grey',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:grey', 'group:leaves'},
		{'dye:grey', 'group:leaves', 'dye:grey'},
	}
})


minetest.register_node("balloonblocks:pink", {
  description = "Pink balloon",
  tiles = {"balloonblocks_pink.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placePink,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:pink',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:magenta', 'group:leaves'},
		{'dye:magenta', 'group:leaves', 'dye:magenta'},
	}
})


minetest.register_node("balloonblocks:brown", {
  description = "Brown balloon",
  tiles = {"balloonblocks_brown.png"},
	groups = state.groups,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeBrown,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:brown',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'dye:brown', 'group:leaves'},
		{'dye:brown', 'group:leaves', 'dye:brown'},
	}
})

-- Extra crafting for the normal balloonblocks--

minetest.register_craft({
	output = 'balloonblocks:green',
	type = 'shapeless',
	recipe = { 'balloonblocks:yellow', 'dye:blue' }
})

minetest.register_craft({
	output = 'balloonblocks:green',
	type = 'shapeless',
	recipe = { 'dye:yellow', 'balloonblocks:blue' }
})

minetest.register_craft({
	output = 'balloonblocks:orange',
	type = 'shapeless',
	recipe = { 'balloonblocks:yellow', 'dye:red' }
})

minetest.register_craft({
	output = 'balloonblocks:orange',
	type = 'shapeless',
	recipe = { 'dye:yellow', 'balloonblocks:red' }
})

minetest.register_craft({
	output = 'balloonblocks:purple',
	type = 'shapeless',
	recipe = { 'balloonblocks:red', 'dye:blue' }
})

minetest.register_craft({
	output = 'balloonblocks:purple',
	type = 'shapeless',
	recipe = { 'dye:red', 'balloonblocks:blue' }
})

minetest.register_craft({
	output = 'balloonblocks:grey',
	type = 'shapeless',
	recipe = { 'balloonblocks:white', 'dye:black' }
})

minetest.register_craft({
	output = 'balloonblocks:grey',
	type = 'shapeless',
	recipe = { 'dye:white', 'balloonblocks:black' }
})

minetest.register_craft({
	output = 'balloonblocks:pink',
	type = 'shapeless',
	recipe = { 'balloonblocks:white', 'dye:red' }
})

minetest.register_craft({
	output = 'balloonblocks:pink',
	type = 'shapeless',
	recipe = { 'dye:white', 'balloonblocks:red' }
})

minetest.register_craft({
	output = 'balloonblocks:brown',
	type = 'shapeless',
	recipe = { 'balloonblocks:green', 'dye:red' }
})

minetest.register_craft({
	output = 'balloonblocks:brown',
	type = 'shapeless',
	recipe = { 'dye:green', 'balloonblocks:red' }
})

-- Glowing balloonblocks --

minetest.register_node("balloonblocks:glowing_red", {
  description = "Glowing red balloon",
  tiles = {"balloonblocks_red.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowRed,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_red',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:red', 'group:leaves', 'dye:red'},
	}
})

minetest.register_node("balloonblocks:glowing_yellow", {
	description = "Glowing yellow balloon",
	tiles = {"balloonblocks_yellow.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowYellow,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_yellow',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:yellow', 'group:leaves', 'dye:yellow'},
	}
})

minetest.register_node("balloonblocks:glowing_green", {
  description = "Glowing green balloon",
  tiles = {"balloonblocks_green.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowGreen,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_green',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:green', 'group:leaves', 'dye:green'},
	}
})

minetest.register_node("balloonblocks:glowing_blue", {
  description = "Glowing blue balloon",
  tiles = {"balloonblocks_blue.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowBlue,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_blue',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:blue', 'group:leaves', 'dye:blue'},
	}
})

minetest.register_node("balloonblocks:glowing_black", {
  description = "Glowing black balloon",
  tiles = {"balloonblocks_black.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowBlack,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_black',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:black', 'group:leaves', 'dye:black'},
	}
})

minetest.register_node("balloonblocks:glowing_white", {
  description = "Glowing white balloon",
  tiles = {"balloonblocks_white.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowWhite,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_white',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:white', 'group:leaves', 'dye:white'},
	}
})

minetest.register_node("balloonblocks:glowing_orange", {
  description = "Glowing orange balloon",
  tiles = {"balloonblocks_orange.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowOrange,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_orange',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:orange', 'group:leaves', 'dye:orange'},
	}
})

minetest.register_node("balloonblocks:glowing_purple", {
  description = "Glowing purple balloon",
  tiles = {"balloonblocks_purple.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowPurple,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_purple',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:violet', 'group:leaves', 'dye:violet'},
	}
})

minetest.register_node("balloonblocks:glowing_grey", {
  description = "Glowing grey balloon",
  tiles = {"balloonblocks_grey.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowGrey,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_grey',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:grey', 'group:leaves', 'dye:grey'},
	}
})


minetest.register_node("balloonblocks:glowing_pink", {
  description = "Glowing pink balloon",
  tiles = {"balloonblocks_pink.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowPink,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_pink',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:magenta', 'group:leaves', 'dye:magenta'},
	}
})


minetest.register_node("balloonblocks:glowing_brown", {
  description = "Glowing brown balloon",
  tiles = {"balloonblocks_brown.png"},
	groups = state.groups,
	light_source = 30,
	paramtype = "light",
	sunlight_propagates = true,
	on_secondary_use = state.placeGlowBrown,
	sounds = state.sounds
})

minetest.register_craft({
	output = 'balloonblocks:glowing_brown',
	recipe = {
		{'group:leaves', 'group:leaves', 'group:leaves'},
		{'group:leaves', 'default:torch', 'group:leaves'},
		{'dye:brown', 'group:leaves', 'dye:brown'},
	}
})

-- Extra crafting for the glowing balloons--

minetest.register_craft({
	output = 'balloonblocks:glowing_red',
	type = 'shapeless',
	recipe = { 'balloonblocks:red', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_yellow',
	type = 'shapeless',
	recipe = { 'balloonblocks:yellow', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_green',
	type = 'shapeless',
	recipe = { 'balloonblocks:green', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_blue',
	type = 'shapeless',
	recipe = { 'balloonblocks:blue', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_black',
	type = 'shapeless',
	recipe = { 'balloonblocks:black', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_white',
	type = 'shapeless',
	recipe = { 'balloonblocks:white', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_orange',
	type = 'shapeless',
	recipe = { 'balloonblocks:orange', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_purple',
	type = 'shapeless',
	recipe = { 'balloonblocks:purple', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_pink',
	type = 'shapeless',
	recipe = { 'balloonblocks:pink', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_grey',
	type = 'shapeless',
	recipe = { 'default:torch', 'balloonblocks:grey' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_brown',
	type = 'shapeless',
	recipe = { 'balloonblocks:brown', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_green',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_yellow', 'dye:blue' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_green',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_blue', 'dye:yellow' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_orange',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_red', 'dye:yellow' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_orange',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_yellow', 'dye:red' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_purple',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_blue', 'dye:red' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_purple',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_red', 'dye:blue' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_pink',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_white', 'dye:red' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_pink',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_red', 'dye:white' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_grey',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_white', 'dye:black' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_grey',
	type = 'shapeless',
	recipe = { 'dye:white', 'balloonblocks:glowing_black' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_brown',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_red', 'dye:green' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_brown',
	type = 'shapeless',
	recipe = { 'balloonblocks:glowing_green', 'dye:red' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_green',
	type = 'shapeless',
	recipe = { 'balloonblocks:yellow', 'dye:blue', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_green',
	type = 'shapeless',
	recipe = { 'balloonblocks:blue', 'dye:yellow', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_orange',
	type = 'shapeless',
	recipe = { 'balloonblocks:red', 'dye:yellow', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_orange',
	type = 'shapeless',
	recipe = { 'balloonblocks:yellow', 'dye:red', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_purple',
	type = 'shapeless',
	recipe = { 'balloonblocks:blue', 'dye:red', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_purple',
	type = 'shapeless',
	recipe = { 'balloonblocks:red', 'dye:blue', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_pink',
	type = 'shapeless',
	recipe = { 'balloonblocks:white', 'dye:red', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_pink',
	type = 'shapeless',
	recipe = { 'balloonblocks:red', 'dye:white', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_grey',
	type = 'shapeless',
	recipe = { 'balloonblocks:white', 'dye:black', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_grey',
	type = 'shapeless',
	recipe = { 'balloonblocks:black', 'dye:white', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_brown',
	type = 'shapeless',
	recipe = { 'balloonblocks:red', 'dye:green', 'default:torch' }
})

minetest.register_craft({
	output = 'balloonblocks:glowing_brown',
	type = 'shapeless',
	recipe = { 'balloonblocks:green', 'dye:red', 'default:torch' }
})
