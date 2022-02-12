-- tp_manage/init.lua
tp_manage = {}
tp_manage.spawn_pos = {x=0, y=3, z=0}
local contexts = {}

if minetest.setting_get_pos("static_spawnpoint") then
    tp_manage.spawn_pos = minetest.setting_get_pos("static_spawnpoint")
end

-- Returns false if the player is not allowed to teleport
-- Returns true if the player is allowed to teleport
tp_manage.can_teleport = function(name)
   -- Players cannot teleport while carrying drug items
   local has_drugs, item = drug_wars.player_has_drugs(name)
   if has_drugs == true then
      minetest.chat_send_player(name, "You cannot teleport while carrying drug paraphernalia ("..item..")")
      return false
   end
   return true
end

tp_manage.teleport_player = function(name, dest_pos)
   local player = minetest.get_player_by_name(name)
   
   if player == nil then
      return false
   end
   
   if tp_manage.can_teleport(name) == false then
      return false
   end


   -- Other things that could be done here:
   -- - Check that the player's velocity is zero
   -- - Turn off fly detection on player for a period of time
   -- - Add a cooldown
   -- - Add a period of time that the player has to stay still
   
   cheat_detection.grant_temp_immunity(minetest.get_player_by_name(name))
   player:set_pos(dest_pos)
   return true
end



function tp_manage.teleport_to_spawn(name)
    if name == nil then
        return false
    end  
    tp_manage.teleport_player(name, tp_manage.spawn_pos)
    
end

minetest.register_chatcommand("spawn", {
    description = "Teleport you to spawn point.",
    func = tp_manage.teleport_to_spawn,
})
