-- playerfactions/offline_raiding.lua



--[[ 
   This file implements the following rules: 
   - A faction is raidable if a member is currently online
   - A faction is raidable if a member was online within the past 
   factions.prot_delay_time seconds
   - A faction is raidable if no member has been online for atleast 
   factions.prot_expire_time seconds
]]--

factions.update_interval = 5 
factions.prot_expire_time = 20
factions.prot_delay_time = 10

-- Returns true if faction fname can be raided, false otherwise.
factions.is_faction_raidable = function(fname)
   local fact = facts[fname] 

   if fact == nil then
      return nil
   end
   local time_now = os.time()
   if fact.last_online == nil then
      fact.last_online = time_now
   end
   
   local secs_since_online = os.difftime(time_now, fname.last_online)

   if secs_since_online > factions.prot_expire_time then
      return true
   end
   
   if secs_since_online < factions.prot_delay_time then
      return true
   end

   return false
end

factions.get_online_factions = function()
   local online_facts = {}
   for _, player in pairs(minetest.get_connected_players()) do
      if player ~= nil then
	 local name = player:get_player_name()
	 local player_fact = factions.get_player_faction(name)
	 if player_fact ~= nil then
	    table.insert(online_facts, player_fact)
	 end
      end
   end
   return online_facts
end

-- Time in seconds since epoch
local start_time = os.time()

factions.update_online_facts = function()
   return

   local online_facts = factions.get_online_factions()
   local time_now = os.time()
   local diff_time = os.difftime(time_now, start_time)
   minetest.log("action", "[playerfactions] Updating online factions list...")

   -- Update last_online for all online factions
   for _, fact in ipairs(online_facts) do
      if facts[fact].last_online == nil then
	 facts[fact].last_online = time_now
      end
      facts[fact].last_online = time_now
   end

   -- Check if any factions became raidable
   for fname, fact in pairs(facts) do
      
   end

   
   
   
   minetest.after(factions.update_interval, factions.update_online_facts)
end

minetest.register_on_mods_loaded(function()
      -- Have a delay here to avoid warning about calling get_connected_players at mod load time.
      minetest.after(factions.update_interval, factions.update_online_facts)
end)

