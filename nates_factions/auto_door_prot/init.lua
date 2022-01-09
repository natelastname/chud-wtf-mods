
-- This mod makes it so that only players who have permission to destroy
-- a given door are able to interact with that door.

auto_door_prot = {}
auto_door_prot.old_can_interact_with_node = default.can_interact_with_node

default.can_interact_with_node = function(player, pos)
   local node = minetest.get_node(pos)
   local pname = player:get_player_name()
   if doors.registered_doors[node.name] or doors.registered_trapdoors[node.name] then
      return simple_protection.can_access(pos, pname)
   end
   return auto_door_prot.old_can_interact_with_node(player, pos)
end
