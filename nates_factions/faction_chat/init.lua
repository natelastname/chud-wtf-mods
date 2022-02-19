minetest.register_chatcommand("t", {
	params = "msg",
	description = "Send a message to members of your faction",
	privs = { interact = true, shout = true },
	func = function(name, param)
		if param == "" then
			return false, "-!- Empty team message, see /help t"
		end
		local fname = factions.get_player_faction(name)
		if fname ~= nil then
		   minetest.log("action", string.format("[CHAT] team message from %s (team %s): %s", name, fname, param))
		   factions.broadcast_to_faction(fname, minetest.colorize("#344feb", "<" .. name .. "> ** " .. param .. " **"))
		else
		   minetest.chat_send_player(name, "You cannot use faction chat because you are not a member of any faction.")
		end
	end
})
