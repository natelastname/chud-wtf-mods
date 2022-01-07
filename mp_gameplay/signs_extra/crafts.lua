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

minetest.register_craft({
      type = "shapeless",
      output = 'signs_extra:blue_banner',
      recipe = {'signs_road:blue_sign', 'signs_road:blue_sign', 'signs_road:blue_sign', 'signs_road:blue_sign'},
})

minetest.register_craft({
      type = "shapeless",
	output = 'signs_extra:billboard',
	recipe = {'default:tinblock', 'dye:white', 'dye:black'},
})

