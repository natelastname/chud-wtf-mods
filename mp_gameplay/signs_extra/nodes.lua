--[[
    signs_extra mod for Minetest - Various road signs with text displayed
    on.
    (c) Hume2
    (c) Pierre-Yves Rollo

    This file is part of signs_road.

    signs_extra is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    signs_extra is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with signs_road.  If not, see <http://www.gnu.org/licenses/>.
--]]

--local S = signs_road.intllib

local models = {
	blue_banner = {
		depth = 1/16,
		width = 64/16,
		height = 12/16,
		entity_fields = {
			maxlines = 1,
			color = "#FFF",
		},
		node_fields = {
		   visual_scale = 1,
			description = "Blue banner",
			tiles = { "signs_extra_blue_sides.png", "signs_extra_blue_sides.png",
			          "signs_extra_blue_sides.png", "signs_extra_blue_sides.png",
			          "signs_extra_blue_sides.png", "signs_extra_blue_banner.png" },
			inventory_image = "signs_extra_blue_banner_item.png",
		},
	},
	billboard = {
		depth = 2/16,
		width = 80/16,
		height = 48/16,
		entity_fields = {
			maxlines = 4,
			color = "#000",
		},
		node_fields = {
		   visual_scale = 1,
			description = "Billboard",
			tiles = { "signs_extra_billboard_side.png", "signs_extra_billboard_side.png",
			          "signs_extra_billboard_side.png", "signs_extra_billboard_side.png",
			          "signs_extra_billboard_side.png", "signs_extra_billboard.png" },
			inventory_image = "signs_extra_billboard_item.png",
		},
	},
}

-- Node registration
for name, model in pairs(models)
do
	signs_api.register_sign("signs_extra", name, model)
end
