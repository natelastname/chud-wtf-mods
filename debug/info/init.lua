minetest.register_chatcommand("info_item", {
	params = "",
	description = "name of item in hand",
	privs = {},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player == nil then
			minetest.log("error", "Unable to get info, player is nil")
			return true -- Handled chat message
		end
		if player:get_wielded_item():is_empty() then
			minetest.chat_send_player(name, 'Unable to get info, no item in hand.')
			return
		end
		
		local item_name = player:get_wielded_item():get_name()
		local item_count = player:get_wielded_item():get_count()
		local item_wear = player:get_wielded_item():get_wear()
		minetest.chat_send_player(name, 'info: item name = '.. item_name ..', count = '.. item_count ..', wear = '.. item_wear ..'')
	end,
})

minetest.register_chatcommand("info_above", {
	params = "",
	description = "name of node the player is standing in",
	privs = {},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player == nil then
			minetest.log("error", "Unable to get info, player is nil")
			return true -- Handled chat message
		end
		local pos = player:getpos()
		pos = {x=math.floor(pos.x+0.5), y=math.floor(pos.y+0.5), z=math.floor(pos.z+0.5)}
		pos = {x=pos.x, y=pos.y, z=pos.z}
		
		local node = minetest.get_node(pos)
		minetest.chat_send_player(name, 'info: node name = '.. node.name ..'')
	end,
})

minetest.register_chatcommand("info_under", {
	params = "",
	description = "name of node under player",
	privs = {},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player == nil then
			minetest.log("error", "Unable to get info, player is nil")
			return true -- Handled chat message
		end
		local pos = player:getpos()
		pos = {x=math.floor(pos.x+0.5), y=math.floor(pos.y+0.5), z=math.floor(pos.z+0.5)}
		pos = {x=pos.x, y=pos.y-1, z=pos.z}
		
		local node = minetest.get_node(pos)
		minetest.chat_send_player(name, 'info: node name = '.. node.name ..'')
	end,
})
