-- Translation support
local S = minetest.get_translator("playerfactions")

minetest.register_privilege("playerfactions_admin", {description = S("Allow the use of all playerfactions commands"), give_to_singleplayer = false})

-- Data
factions = {}
-- This variable "version" can be used by other mods to check the compatibility of this mod
factions.version = 2

facts = {}
local storage = minetest.get_mod_storage()

-- Factions are stored in plain text rather than a database. The whole thing
-- is loaded into memory on server start, and serialized multiple times during
-- runtime. This should be fine for now, but it could become an issue with
-- thousands of players/factions.
if storage:get_string("facts") ~= "" then
   facts = minetest.deserialize(storage:get_string("facts"))
end
-- Here, we could do some basic checks to make sure there are no invalid factions
-- (e.g., factions with no members)

-- Make sure there are no factions with no value for last_online 
for fname, fact in pairs(facts) do
   if fact.last_online == nil then
      facts[fname].last_online = 0
   end
end

factions.mode_unique_faction = minetest.settings:get_bool("player_factions.mode_unique_faction", true)
factions.max_members_list = tonumber(minetest.settings:get("player_factions.max_members_list")) or 50

function factions.save_factions()
   storage:set_string("facts", minetest.serialize(facts))
end

local function factions_send_player(player, message)
   local msg1 = minetest.colorize("#32a852", "[Factions] ")
   local msg = msg1 .. message
   minetest.chat_send_player(player, msg)
end


local function table_copy(data)
   local copy = {}
   if type(data) == "table" then
      for k,v in pairs(data) do
         copy[k]=table_copy(v)
      end
      return copy
   else
      return data
   end
end


-- Return a list of players in faction fname that are currently online
function factions.online_players_in_faction(fname)
   local res = {}
   if facts[fname] == nil then
      return res
   end

   for key, val in pairs(facts[fname].members) do
      local name = key

      if minetest.get_player_by_name(name) ~= nil then
         table.insert(res, name)
      end
   end
   return res
end

-- Send a message to all online members of faction fname
function factions.broadcast_to_faction(fname, msg)
   for _, name in ipairs(factions.online_players_in_faction(fname)) do
      minetest.chat_send_player(name, msg)
   end
end

-- Data manipulation
function factions.get_facts()
   return table_copy(facts)
end

function factions.player_is_in_faction(fname, player_name)
   if facts[fname] == nil then
      return false
   end
   return facts[fname].members[player_name]
end

-- This performs an O(n) search where n is the number of factions. Not optimal.
function factions.get_player_factions(name)
   local player_factions = nil
   for fname, fact in pairs(facts) do
      if fact.members[name] then
         if not player_factions then
            player_factions = {}
         end
         table.insert(player_factions, fname)
      end
   end
   if player_factions == nil then
      return nil
   end
   
   if #player_factions > 1 and player_factions.mode_unique_faction == true then
      minetest.log("warning", "Player ".. name.." is a member of multiple factions with player_factions.mode_unique_faction=true")
   end

   return player_factions
end

-- Returns faction name if player is a member of a faction, nil otherwise.
function factions.get_player_faction(name)
   if factions.mode_unique_faction == false then
      minetest.log("warning", "Call to factions.get_player_faction with setting player_factions.mode_unique_faction=false.")
   end
   local facts = factions.get_player_factions(name)
   if facts == nil then
      return nil
   end
   if #facts ~= 1 then
      minetest.log("warning", "Player ".. name .. " is not a member of one single faction.")
      return facts[1]
   end
   return facts[1]
end

function factions.get_owned_factions(name)
   local own_factions = nil
   for fname, fact in pairs(facts) do
      if fact.owner == name then
         if not own_factions then
            own_factions = {}
         end
         table.insert(own_factions, fname)
      end
   end
   return own_factions
end

function factions.get_administered_factions(name)
   local adm_factions = {}
   for fname, fact in pairs(facts) do
      if minetest.get_player_privs(name).playerfactions_admin or fact.owner == name then
         if not adm_factions then
            adm_factions = {}
         end
         table.insert(adm_factions, fname)
      end
   end
   return adm_factions
end

function factions.get_owner(fname)
   if facts[fname] == nil then
      return false
   end
   return facts[fname].owner
end

function factions.chown(fname, owner)
   if facts[fname] == nil then
      return false
   end
   facts[fname].owner = owner
   factions.save_factions()
   return true
end

function factions.register_faction(fname, founder, pw)
   if facts[fname] ~= nil then
      return false
   end
   facts[fname] = {
      name = fname,
      owner = founder,
      password = pw,
      members = {[founder] = true},
      home = "",
      time_created = os.time(),
      last_online = os.time()
   }
   factions.save_factions()
   return true
end

function factions.disband_faction(fname)
   if facts[fname] == nil then
      return false
   end
   facts[fname] = nil
   factions.save_factions()
   simple_protection.delete_faction_claims(fname)
   return true
end

function factions.get_password(fname)
   if facts[fname] == nil then
      return false
   end
   return facts[fname].password
end

function factions.set_password(fname, password)
   if facts[fname] == nil then
      return false
   end
   facts[fname].password = password
   factions.save_factions()
   return true
end

function factions.join_faction(fname, player)
   if facts[fname] == nil or not minetest.player_exists(player) then
      return false
   end
   facts[fname].members[player] = true
   factions.save_factions()
   return true
end

function factions.leave_faction(fname, player_name)
   if facts[fname] == nil or not minetest.player_exists(player_name) then
      return false
   end
   facts[fname].members[player_name] = nil
   factions.save_factions()
   return true
end


function factions.set_f_home(player_name)
   local player = minetest.get_player_by_name(player_name)
   if player == nil then
      factions_send_player(player_name, "pos nil")
      return
   end
   local pos = player:get_pos()
   if pos == nil then
      factions_send_player(player_name, "pos nil")
      return
   end
   local fname = factions.get_player_faction(player_name)
   if fname == nil then
      factions_send_player(player_name, "You are not a member of any faction. Create or join a faction first.")
      return
   end

   local data = simple_protection.get_claim(pos)

   if data == nil or fname ~= data.owner then
      factions_send_player(player_name, "You can only set your faction's home on land that you have claimed.")
      return
   end
   


   
   facts[fname].home = pos
   factions.save_factions()
   factions_send_player(player_name, "Faction home successfully set.")
end

function factions.tp_f_home(player_name)
   local player = minetest.get_player_by_name(player_name)
   if player == nil then
      return
   end
   local pos = player:get_pos()
   if pos == nil then
      return
   end
   local fname = factions.get_player_faction(player_name)
   if fname == nil then
      factions_send_player(player_name, "You are not a member of any faction. Create or join a faction first.")
      return
   end
   local f_home = facts[fname].home
   if f_home == "" then
      factions_send_player(player_name, "Your faction does not have a home position. Set one using '/f sethome' first.")
      return
   end
   if tp_manage.teleport_player(player_name, f_home) == true then
      factions_send_player(player_name, "Teleported to faction home.")
   end
end

function factions.join(name, faction_name, password)
   if factions.get_player_faction(name) ~= nil and factions.mode_unique_faction then
      factions_send_player(name, S("You are already in a faction."))
   elseif facts[faction_name] == nil then
      factions_send_player(name, S("The faction @1 doesn't exist.", faction_name))
   elseif factions.get_password(faction_name) ~= password then
      factions_send_player(name, S("Permission denied: Wrong password."))
   else
      if factions.join_faction(faction_name, name) then
         factions_send_player(name, S("Joined @1.", faction_name))
      else
         factions_send_player(name, S("Error on joining."))
      end
   end

end
function factions.disband(name)
   local faction_name = factions.get_player_faction(name)

   if faction_name == nil then
      factions_send_player(name, "You are not a member of a faction.")
      return
   end
   if facts[faction_name].owner ~= name then
      factions_send_player(name, "Only the owner of a faction can disband.")
      return
   end
   factions.disband_faction(faction_name)
   factions_send_player(name, S("Disbanded @1.", faction_name))
end

-- If faction_name is nil, it is looking up by name
function factions.info(name, faction_name)
   if faction_name == nil then
      factions_send_player(name, S("No faction name provided."))
      return true
   end

   if facts[faction_name] == nil then
      factions_send_player(name, S("This faction doesn't exists."))
   else
      local fmembers = ""
      if table.getn(facts[faction_name].members) > factions.max_members_list then
         fmembers = S("The faction has more than @1 members, the members list can't be shown.", factions.max_members_list)
      else
         for play,_ in pairs(facts[faction_name].members) do
            if fmembers == "" then
               fmembers = play
            else
               fmembers = fmembers..", "..play
            end
         end
      end
      local msg = ""
      msg = msg .. "Name: " .. faction_name .. "\n"
      msg = msg .. "Owner: " .. factions.get_owner(faction_name) .. "\n"
      msg = msg .. "Currently raidable: " .. tostring(factions.is_faction_raidable(faction_name)) .. "\n"
      msg = msg .. "Members: " .. fmembers .. "\n"
      
      factions_send_player(name, msg)
      if factions.get_owner(faction_name) == name or minetest.get_player_privs(name).playerfactions_admin then
         factions_send_player(name, S("Password: @1", factions.get_password(faction_name)))
      end
   end
end
function factions.player_info(name, player_name)
   local player_factions = factions.get_player_factions(player_name)
   if not player_factions then
      factions_send_player(name, S("This player doesn't exists or is in no faction"))
   else
      local str_owner = ""
      local str_member = ""
      for _,v in ipairs(player_factions) do
         if str_member == "" then
            str_member = str_member..v
         else
            str_member = str_member..", "..v
         end
      end
      factions_send_player(name, S("@1 is in the following factions: @2.", player_name, str_member))
      local owned_factions = factions.get_owned_factions(player_name)
      if not owned_factions then
         factions_send_player(name, S("This player is the owner of no faction."))
      else
         for _,v in ipairs(owned_factions) do
            if str_owner == "" then
               str_owner = str_owner..v
            else
               str_owner = str_owner..", "..v
            end
         end
         factions_send_player(name, S("This player is the owner of the following factions: @1.", str_owner))
      end
      if minetest.get_player_privs(player_name).playerfactions_admin then
         factions_send_player(name, S("@1 has the playerfactions_admin privilege so they can admin every faction.", player_name))
      end
   end
end

function factions.list(name)
   local faction_list = {}
   for k, f in pairs(facts) do
      table.insert(faction_list, k)
   end
   if #faction_list ~= 0 then
      factions_send_player(name, S("Factions (@1): @2.", #faction_list, table.concat(faction_list, ", ")))
   else
      factions_send_player(name, S("There are no factions yet."))
   end
end

function factions.create(name, faction_name, password)
   if factions.mode_unique_faction and factions.get_player_faction(name) ~= nil then
      factions_send_player(name, S("You are already in a faction."))
   elseif faction_name == nil then
      factions_send_player(name, S("Missing faction name."))
   elseif password == nil then
      factions_send_player(name, S("Missing password."))
   elseif facts[faction_name] ~= nil then
      factions_send_player(name, S("That faction already exists."))
   else
      factions.register_faction(faction_name, name, password)
      factions_send_player(name, S("Registered @1.", faction_name))
   end
end

function factions.leave(name)
   local faction_name = factions.get_player_faction(name)
   if faction_name == nil then
      factions_send_player(name, S("You are not in a faction."))
   elseif factions.get_owner(faction_name) == name then
      factions_send_player(name, S("You cannot leave your own faction, change owner or disband it."))
   else
      if factions.leave_faction(faction_name, name) then
         factions_send_player(name, S("Left @1.", faction_name))
      else
         factions_send_player(name, S("Error on leaving faction."))
      end
   end
end
function factions.kick(name, target)
   local faction_name = nil
   local own_factions = factions.get_administered_factions(name)
   local number_factions = table.getn(own_factions)
   if number_factions ~= 1 then
      factions_send_player(name, S("You are not the owner of a faction, you can't use this command."))
      return
   end
   faction_name = own_factions[1]
   if faction_name == nil then
      factions_send_player(name, S("You are the owner of many factions, you have to choose one of them: @1.", table.concat(own_factions, ", ")))
   elseif target == nil then
      factions_send_player(name, S("Missing player name."))
   elseif factions.get_owner(faction_name) ~= name and not minetest.get_player_privs(name).playerfactions_admin then
      factions_send_player(name, S("Permission denied: You are not the owner of this faction, and don't have the playerfactions_admin privilege."))
   elseif not facts[faction_name].members[target] then
      factions_send_player(name, S("This player is not in the specified faction."))
   elseif target == factions.get_owner(faction_name) then
      factions_send_player(name, S("You cannot kick the owner of a faction, use '/factions chown <player> [faction]' to change the ownership."))
   else
      if factions.leave_faction(faction_name, target) then
         factions_send_player(name, S("Kicked @1 from faction.", target))
      else
         factions_send_player(name, S("Error kicking @1 from faction.", target))
      end
   end
end

function factions.passwd(name, password)
   local faction_name = factions.get_player_faction(name)
   local own_factions = factions.get_administered_factions(name)
   local number_factions = table.getn(own_factions)
   if number_factions ~= 1 then
      factions_send_player(name, S("You are the owner of no faction, you can't use this command."))
      return
   end

   if faction_name == nil then
      factions_send_player(name, S("You are the owner of many factions, you have to choose one of them: @1.", table.concat(own_factions, ", ")))
   elseif password == nil then
      factions_send_player(name, S("Missing password."))
   elseif factions.get_owner(faction_name) ~= name and not minetest.get_player_privs(name).playerfactions_admin then
      factions_send_player(name, S("Permission denied: You are not the owner of this faction, and don't have the playerfactions_admin privilege."))
   else
      if factions.set_password(faction_name, password) then
         factions_send_player(name, S("Password has been updated."))
      else
         factions_send_player(name, S("Failed to change password."))
      end
   end
end

function factions.chown_cmd(name, target)
   local own_factions = factions.get_administered_factions(name)
   local number_factions = table.getn(own_factions)
   local faction_name = factions.get_player_faction(name)
   if number_factions ~= 1 then
      factions_send_player(name, "You are not the owner of any faction")
      return
   end
   if faction_name == nil then
      factions_send_player(name, "You are not the owner of any faction")
   elseif target == nil then
      factions_send_player(name, S("Missing player name."))
   elseif name ~= factions.get_owner(faction_name) and not minetest.get_player_privs(name).playerfactions_admin then
      factions_send_player(name, S("Permission denied: You are not the owner of this faction, and don't have the playerfactions_admin privilege."))
   elseif not facts[faction_name].members[target] then
      factions_send_player(name, S("@1 isn't in your faction.", target))
   else
      if factions.chown(faction_name, target) then
         factions_send_player(name, S("Ownership has been transferred to @1.", target))
      else
         factions_send_player(name, S("Failed to transfer ownership."))
      end
   end
end

function factions.force_join(name, target, faction_name)
   if not minetest.get_player_privs(name).playerfactions_admin then
      factions_send_player(name, S("Permission denied: You can't use this command, playerfactions_admin priv is needed."))
      return
   end
   if faction_name == nil then
      factions_send_player(name, "Missing faction name")
      return
   end
   if facts[faction_name] == nil then
      factions_send_player(name, S("The faction @1 doesn't exist.", faction_name))
   elseif not minetest.player_exists(target) then
      factions_send_player(name, S("The player doesn't exist."))
   elseif factions.mode_unique_faction and factions.get_player_faction(target) ~= nil then
      factions_send_player(name, S("The player is already in the faction \"@1\".",factions.get_player_faction(target)))
   else
      if factions.join_faction(faction_name, target) then
         factions_send_player(name, S("@1 is now a member of the faction @2.", target, faction_name))
      else
         factions_send_player(name, S("Error on adding @1 into @2.", target, faction_name))
      end
   end
end

function factions.debug(name)
   if not minetest.get_player_privs(name).playerfactions_admin then
      factions_send_player(name, S("Permission denied: You can't use this command, playerfactions_admin priv is needed."))
   else
      print(dump(facts))
   end
end

-- Chat commands
local function handle_command(name, param)
   local params = {}
   for p in string.gmatch(param, "[^%s]+") do
      table.insert(params, p)
   end
   if params == nil then
      return false
   end
   local action = params[1]
   if action == "nil" then
      return false
   elseif action == "create" then
      local faction_name = params[2]
      local password = params[3]
      factions.create(name, faction_name, password)
   elseif action == "disband" then
      factions.disband(name)
   elseif action == "list" then
      factions.list(name)
      return true
   elseif action == "info" then
      local faction_name = params[2]
      factions.info(name, faction_name)
   elseif action == "player_info" then
      local player_name = params[2]
      factions.player_info(name, player_name)
   elseif action == "join" then
      local faction_name = params[2]
      local password = params[3]
      factions.join(name, faction_name, password)
   elseif action == "leave" then
      factions.leave(name)
   elseif action == "kick" then
      local target = params[2]
      factions.kick(name, target)
   elseif action == "passwd" then
      local password = params[2]
      factions.passwd(name, password)
   elseif action == "chown" then
      local target = params[2]
      factions.chown_cmd(name, target)
   elseif action == "forcejoin" then
      local target = params[2]
      local faction_name = params[3]
      factions.force_join(name, target, faction_name)
   elseif action == "debug" then
      factions.debug(name)
   elseif action == "invite" then
      factions_send_player(name, "Invite is not yet implemented. Use /f join <faction> <password>")
   elseif action == "showclaim" then
      simple_protection.show(name)
   elseif action == "claimlist" then
      simple_protection.list(name)
   elseif action == "radar" then
      simple_protection.radar(name)
   elseif action == "claim" then
      simple_protection.claim(name)
   elseif action == "unclaim" then
      simple_protection.unclaim(name)
   elseif action == "unclaimall" then
      simple_protection.delete_all_claims(name)
   elseif action == "sethome" then
      factions.set_f_home(name)
   elseif action == "home" then
      factions.tp_f_home(name)
   else
      factions_send_player(name, "Unknown subcommand. Run '/help f' for help.")
   end
   return true
end

minetest.register_chatcommand("f", {
                                 params = "create <faction> <password>: "..S("Create a new faction").."\n"
                                    .."list: "..S("List available factions").."\n"
                                    .."info <faction>: "..S("See information on a faction").."\n"
                                    .."player_info <player>: "..S("See information on a player").."\n"
                                    .."join <faction> <password>: "..S("Join an existing faction").."\n"
                                    .."leave: "..S("Leave your faction").."\n"
                                    .."kick <player>: "..S("Kick someone from your faction or from the given faction").."\n"
                                    .."disband <password>: "..S("Disband your faction or the given faction").."\n"
                                    .."passwd <password>: "..S("Change your faction's password or the password of the given faction").."\n"
                                    .."chown <player>: "..S("Transfer ownership of your faction").."\n"
                                    .."invite <player>: "..S("Invite a player to your faction.").."\n"
                                    .."forcejoin <player> <faction>: "..S("Add player to a faction. Requires playerfactions_admin priv.").."\n"
                                    .."debug: ".. "Print factions table to logs. Requires playerfactions_admin priv." .."\n"
                                    .."invite <player>: ".."Invite a player to your faction.".."\n"
                                    .."showclaim: ".."Make the boundaries of the currently occupied claim visible.".."\n"
                                    .."claimlist: ".."List the location of the faction's claims.".."\n"
                                    .."radar: ".."Show a map of nearby claims.".."\n"
                                    .."claim: ".."Attempt to claim the land that you are standing on.".."\n"
                                    .."unclaim: ".."Attempt to unclaim the land that you are standing on.".."\n"
                                    .."unclaimall: ".."Unclaim all faction territory.".."\n"
                                    .."sethome: ".."Set the faction home position.".."\n"
                                    .."home: ".."Teleport to the faction home position.".."\n",
                                 description = "",
                                 privs = {},
                                 func = handle_command
})

dofile(minetest.get_modpath("playerfactions").."/offline_raiding.lua")
