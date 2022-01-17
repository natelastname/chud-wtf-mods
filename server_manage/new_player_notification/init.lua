-- new_player_notification/init.lua

minetest.register_privilege("new_player_notification", {
			       description = "Hear a notification when a new player joins",
			       give_to_singleplayer = false
})

minetest.register_on_joinplayer(function(player)
      for _, player in ipairs(minetest.get_connected_players()) do
	 local pname = player:get_player_name()
	 if minetest.get_player_privs(pname).new_player_notification then
	    minetest.sound_play("new_player_notification_bell", {
				   to_player = pname,
				   gain=0.4,
				   fade=0.0,
				   pitch=3.0
				       }, true)


	 end
      end
end)
