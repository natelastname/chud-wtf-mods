-- tp_manage/init.lua
tp_manage = {}

-- Returns false if the player is not allowed to teleport
-- Returns true if the player is allowed to teleport
tp_manage.can_teleport = function(name)
   local has_drugs, item = drug_wars.player_has_drugs(name)
   if has_drugs == true then
      minetest.chat_send_player(name, "You cannot teleport while carrying drug paraphernalia ("..item..")")
      return false
   end
   return true
end
