-- Licensed under CC0.
-- Painting textures from Stunt Rally <https://code.google.com/p/vdrift-ogre/>, licensed under CC0.

local paintings = {}

minetest.log("LOADING PAINTINGS MOD")
paintings.dyes = {
	{"white",      "White"},
	{"grey",       "Grey"},
	{"black",      "Black"},
	{"red",        "Red"},
	{"yellow",     "Yellow"},
	{"green",      "Green"},
	{"cyan",       "Cyan"},
	{"blue",       "Blue"},
	{"magenta",    "Magenta"},
	{"orange",     "Orange",},
	{"violet",     "Violet"},
	{"brown",      "Brown"},
	{"pink",       "Pink"},
	{"dark_grey",  "DarkGrey"},
	{"dark_green", "DarkGreen"},
}

for _, row in ipairs(paintings.dyes) do
	local name = row[1]
	local desc = row[2]
	local icon = "painting_icon_outer.png^(painting_icon_inner.png^[colorize:"..desc..":128)"
	minetest.register_node("paintings:" .. name, {
                             description = desc .. " Painting",
                             drawtype = "nodebox",
                             tiles = {"paintings_" .. name .. ".png"},
                             inventory_image = icon,
                             wield_image = icon,
                             paramtype = "light",
                             paramtype2 = "wallmounted",
                             sunlight_propagates = true,
                             walkable = false,
                             node_box = {
                                type = "wallmounted",
                                wall_top    = {-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
                                wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
                                wall_side   = {-0.5, -0.5, -0.5, -0.4375, 0.5, 0.5},
                             },
                             groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, flammable = 3},
                             sounds = default.node_sound_wood_defaults(),
	})
	minetest.register_craft({
         output = "paintings:" .. name,
         recipe = {
            {"group:stick", "group:stick", "group:stick"},
            {"group:stick", "wool:" .. name, "group:stick"},
            {"group:stick", "group:stick", "group:stick"},
         }
	})
end
