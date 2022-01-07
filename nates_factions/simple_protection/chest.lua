local sp = simple_protection
local S = sp.translator

-- A shared chest for simple_protection but works with other protection mods too

local function get_item_count(pos, player, count)
	local name = player and player:get_player_name()
	if not name or minetest.is_protected(pos, name) then
		return 0
	end
	return count
end
