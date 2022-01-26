minetest.register_on_cheat(function(player, cheat)
      amtac.handle_cheater(player, cheat.type, {})
end)
