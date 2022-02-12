-- playerfactions/offline_raiding.lua


local debug_mode = false

--[[ 
   This file implements the following rules: 
   - A faction is raidable if a member is currently online
   - A faction is raidable if a member was online within the past 
   factions.prot_delay_time seconds
   - A faction is raidable if no member has been online for atleast 
   factions.prot_expire_time seconds
]]--

factions.update_interval = 10
-- 30 minuntes
factions.prot_delay_time = 60*30
-- 3 days
factions.prot_expire_time = 60*60*24*3

if debug_mode then
   factions.update_interval = 2
   factions.prot_expire_time = 20
   factions.prot_delay_time = 10
end

-- Returns true if faction fname can be raided, false otherwise.
factions.is_faction_raidable = function(fname)

   if fname == "" or fname == nil or facts[fname] == nil then
      minetest.log("warning", "[playerfactions] Faction '" .. tostring(fname) .. "' does not exist")
      return false
   end
   
   local fact = facts[fname]
   
   if fact.last_online == nil then
      facts[fname].last_online = 0
   end

   local time_now = os.time()
   local time_logged_off = os.difftime(time_now, fact.last_online)
   if time_logged_off > factions.prot_expire_time then
      return true
   elseif time_logged_off > factions.prot_delay_time then
      return false
   else
      -- The faction is either online, or just logged off
      return true
   end
end

-- return a list of online factions
factions.get_online_factions = function()
   local online_facts = {}
   for _, player in pairs(minetest.get_connected_players()) do
      if player ~= nil then
	 local name = player:get_player_name()
	 local player_fact = factions.get_player_faction(name)
	 if player_fact ~= nil then
	    online_facts[player_fact] = true
	 end
      end
   end
   return online_facts
end

-- Time in seconds since epoch
local start_time = os.time()

-- The raidable status of a faction is dependent only on facts[fname].last_online.
-- However, we also need to prevent sending status update messages every update.
-- This is the purpose of logged_status.
-- Minor problem: this system will cause the server to print the online status
-- of every faction on server start. 
local logged_status = {}


-- Status can either be "raidable" or "unraidable"
local print_fact_status_msg = function(fname, status, reason)

   if logged_status[fname] == status then
      -- The status of this faction has not changed, don't print anything
      return
   end
   
   logged_status[fname] = status
   
   if status == "raidable" then
      local msg1 = minetest.colorize("#32a852", "[Factions] ")
      local msg = msg1 .. "Faction '".. fname .. "' is now raidable (".. reason..".)"
      minetest.chat_send_all(msg)
      return
   end
   
   if status == "unraidable" then
      local msg1 = minetest.colorize("#32a852", "[Factions] ")
      local msg = msg1 .. " Faction '".. fname .. "' is now unraidable (".. reason..".)"
      minetest.chat_send_all(msg)
      return
   end
   
end

-- This might cause problems when there is a large number of factions
-- due to the fact that the dictionary of all factions is serialized
-- often, and certain functions are implemented inefficiently.
local prev_online_facts = {}
factions.update_online_facts = function()

   if false then
      -- This is currently disabled because it's unfinished, and I'm not sure
      -- I even want it in the first place.
      return
   end
   
   local online_facts = factions.get_online_factions()
   local time_now = os.time()
   local diff_time = os.difftime(time_now, start_time)
   minetest.log("action", "[playerfactions] Updating online factions list...")

   -- 1. Update last_online for all online factions.
   -- 2. Detect if an online faction became raidable due to a player being online.  
   for fname, _ in pairs(online_facts) do
      if online_facts[fname] == true and prev_online_facts[fname] == nil then
	 print_fact_status_msg(fname, "raidable", "a member is now online")
      end
      facts[fname].last_online = time_now
   end

   for fname, _ in pairs(prev_online_facts) do
      if online_facts[fname] == nil and prev_online_facts[fname] == true then
	 -- This faction fname becomes raidable in factions.prot_expire_time seconds.
	 -- minetest.chat_send_all("Faction ".. fname .. " logged off")
      end
   end
   
   if debug_mode then
      print("====================================")
      print("Time since logged off:")
   end

   for fname, fact in pairs(facts) do
      local time_logged_off = os.difftime(time_now, fact.last_online)

      if debug_mode then
	 print(fname .. ": " .. tostring(time_logged_off))
      end
      
      if fact.last_online == nil then
	 facts[fname].last_online = 0
      end

      if time_logged_off > factions.prot_expire_time then
	 print_fact_status_msg(fname, "raidable", "offline raid protection expired")
      elseif time_logged_off > factions.prot_delay_time then
	 print_fact_status_msg(fname, "unraidable", "protection delay period expired")
      end
   end
   
   prev_online_facts = online_facts
   
   minetest.after(factions.update_interval, factions.update_online_facts)
end

minetest.register_on_mods_loaded(function()
      -- Have a delay here to avoid warning about calling get_connected_players at mod load time.
      minetest.after(factions.update_interval, factions.update_online_facts)
end)

