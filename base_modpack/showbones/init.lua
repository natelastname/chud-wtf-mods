local showbones_temp = {}                          -- Stores temporary player data (persists until player leaves)

if not minetest.global_exists("showbones") then
   showbones = {
      modname = "Showbones",
      showbones_limit = 3,                         -- How many bones a player may have on the server until pruned.
      datafile = minetest.get_worldpath() .."/showbones.db",
   }
end

local share_bones_time = tonumber(minetest.setting_get("share_bones_time")) or 1200
local share_bones_time_early = tonumber(minetest.setting_get("share_bones_time_early")) or share_bones_time / 4

-- Loads entire showbones database

function showbones.db_load()
   local file = io.open(showbones.datafile, "r")
   print("Reading from database")
   if file then
      local temp_table = minetest.deserialize(file:read("*all"))
      file:close()
      if type(temp_table) == "table" then
         return temp_table
      end
   end   
end


                                                   -- Merges new data with stored data and saves to db

function showbones.db_save(data)
   local orig_db = showbones.db_load() or {}       -- load old db data
   local file = io.open(showbones.datafile, "w")   -- open db for write
   if file then
      if type(data) == "table" then
         for k, v in pairs(data) do                -- add new to old
            orig_db[k] = data[k]
         end
         data = orig_db
      end
      file:write(minetest.serialize(data))
      file:close()
      print("Writing to database")
   end
end

function showbones.is_joined_player(player_name)
   local player = minetest.get_player_by_name(player_name)
   if not player then
      return false, "Player not logged in"
   else
      return true, "Player is logged in"
   end
end
                                                   -- called from on_die_player, or bones:bones when bones dug
function showbones.update_bones_locations(pos, player_name) 
   local player_table = showbones.get_player_table(player_name)
	local bones_locations = player_table.bones_locations
	
	   if table.getn(bones_locations) >= showbones.showbones_limit then
      print(player_name .. " has too many bones! Pruning")
      local count = table.getn(bones_locations)
      while table.getn(bones_locations) >= showbones.showbones_limit do
         local prunepos = bones_locations[count]

         minetest.set_node(prunepos, {name="air"})
         bones_locations[count] = nil
         bones_locations = bones_locations
         prunepos = nil
         count = count-1
      end
   end

   table.insert(bones_locations, 1, pos)           -- add current pos to stored pos's if they are there.
   player_table.bones_locations = bones_locations  -- update with new bones and also pruned
   return player_table
   
end

function showbones.get_player_table(player_name)   -- grabs player table by passing a player_name
   if showbones_temp[player_name] then
      local player_table = showbones_temp[player_name]
      return player_table
   else
      local showbones_db = showbones.db_load() or {}
	   local player_table = showbones_db[player_name] or {}
	   player_table = {
	      hud={},
	      togglehud = "off",
	      bones_locations = player_table["bones_locations"] or {}
	   }
	   return player_table                          -- return created player db entry
   end
end


function showbones.announce_bones(pos, player_name) -- verify bones at pos
   local node = minetest.get_node(pos)
   if node.name == "bones:bones" then
      local meta = minetest.get_meta(pos)
      meta:set_string("showbones_owner", player_name) -- set custom owner as bones owner will vanish eventually.
      print(player_name .. " died and left us bones! " .. minetest.pos_to_string(pos)) -- to console for debugging
      return pos
   end
end




function showbones.hide_hud(player_name)           -- removes showbones waypoints and togglehud = "off"
   local player = minetest.get_player_by_name(player_name)
    showbones_temp[player_name] = showbones.get_player_table(player_name)
    
    for k, v in pairs(showbones_temp[player_name]["hud"]) do
      player:hud_remove(v)
      showbones_temp[player_name]["hud"][k] = nil
    end
    
--[[   
   for i = 1, showbones.showbones_limit do
      if showbones_temp[player_name]["hud"][i] then
         player:hud_remove(i)
         showbones_temp[player_name]["hud"][i] = nil
      end
   end
--]] 
   if next(showbones_temp[player_name]["hud"]) == nil then
      showbones_temp[player_name]["togglehud"] = "off"
   end
end
                                                   -- Creates one Bones waypoint
function showbones.update_hud(bones_locations, i, player_name) 
   local pos = bones_locations[i]
   if not pos then
      return
   end
   
   local meta = minetest.get_meta(pos)
   local time = meta:get_int("time")
	local waypoint_color = "0xffff00" -- yellow, aging
	local waypoint_text = "Your aging bones "
	if time >= (share_bones_time - 10) then
	   waypoint_color = "0xff001e" -- red, old, others may dig
	   waypoint_text = "Your old bones "
	elseif time < (share_bones_time / 2) then
	   waypoint_color = "0x12ff00" -- green, fresh
	   waypoint_text = "Your fresh bones "
	end   
   local player = minetest.get_player_by_name(player_name)  
   showbones_temp[player_name].hud[i] = player:hud_add({
      hud_elem_type = "waypoint",
      number = waypoint_color, -- color according to age of bones.
      name = waypoint_text .. minetest.pos_to_string(pos),
      text = " nodes away",
      world_pos = pos
   })
end


function showbones.show_hud(player_name) 
   showbones_temp[player_name] = showbones.get_player_table(player_name)
                                                   -- make a copy bones_locations to simplify
   local bones_locations = showbones_temp[player_name]["bones_locations"] 
   local total_bones_locations = table.getn(bones_locations)
                                                   -- go through pos's and build a waypoint for each
   for i = 1, showbones.showbones_limit do 
      showbones.update_hud(bones_locations, i, player_name)
   end
   
   
   if next(showbones_temp[player_name]["hud"]) ~= nil then
      showbones_temp[player_name]["togglehud"] = "on"
   end
   
   local message = ""
   if total_bones_locations == 0 then
      message = "[".. showbones.modname .. "] No bones waypoints to show."
      if next(showbones_temp[player_name]["hud"]) == nil then
         showbones_temp[player_name]["togglehud"] = "off"
      end
   elseif total_bones_locations >= 1 and total_bones_locations < showbones.showbones_limit then
      message = "[".. showbones.modname .. "] Your Bones are now shown as " .. total_bones_locations .. " waypoints."
   elseif total_bones_locations >= showbones.showbones_limit then
      message = "[".. showbones.modname .. "] Your Bones are now shown as " .. total_bones_locations .. " waypoints.\nUnclaimed Bones beyond " .. showbones.showbones_limit .. " will be automatically removed from world."
   end
   
   minetest.chat_send_player(player_name, message)
   return true, ""
end

minetest.register_chatcommand("showbones", { 
   params = "",
   description = "Show wayoint markers of bones location(s).",
   func = function(name, param)
      local player = minetest.get_player_by_name(name)
      
      if not player then
         return false, "Player not found"
      end
      
      local player_name = name
                                                   -- toggle off until turned on 
      if showbones_temp[player_name] and showbones_temp[player_name]["togglehud"] == "on" then    
        showbones.hide_hud(player_name)
        minetest.chat_send_player(player_name, "[".. showbones.modname .. "] Bones waypoints now hidden")  
      elseif showbones_temp[player_name]["togglehud"] == "off" then
         showbones.show_hud(player_name)
      end	  

   end,
})

function showbones.clear_bones_pos(player_name, pos)
   showbones_temp[player_name] = showbones.get_player_table(player_name)
   local bones_locations = showbones_temp[player_name]["bones_locations"]
   for k, v in pairs(bones_locations) do           -- add new to old
                                                   -- find match of pos and remove it.
      if v.x == pos.x and v.y == pos.y and v.z == pos.z then 
         bones_locations[k] = nil
      end
   end
   showbones_temp[player_name]["bones_locations"] = bones_locations   
end

function showbones.chat_notify(owner, bones_breaker)
   local messages = { -- add more messages if you want
      bones_breaker .. " just dug your bones!",
      "Hey " .. owner .. ", " .. bones_breaker .. " swiped your loot from your bones.",
      "Too slow " .. owner .. ", your grave was robbed by " .. bones_breaker .. " and you lost all your stuff!",
      "How rude! " .. bones_breaker .. " picked your bones clean! Sharpen your sword and reclaim what is yours!",
      "Seriously? " .. bones_breaker .. " just now stole from your bones. Let's go teach them a thing or two about respect.",
      owner .. "? You taking a nap or what? You just let " .. bones_breaker .. " walk off with your inventory!",
      "You seem to be missing your bones " .. owner .. ", find " .. bones_breaker .. " and get your stuff back!",
      bones_breaker .. " defiled your grave, took your bones and all it contained. A act of war if you ask me."
   }
      
   -- notify owner in chat with one of the above messages.
   minetest.chat_send_player(owner, "[Showbones Mod] " .. messages[math.random (table.getn(messages))])
end

function showbones.bones_removed(pos, player)      -- called by bones:bones on_punch
   local bones_breaker = player:get_player_name()
   local showbones_owner = minetest.get_meta(pos):get_string("showbones_owner")
   if showbones_owner == bones_breaker then        -- bones dug by owner
      showbones.clear_bones_pos(bones_breaker, pos)
      local player_name = bones_breaker
      if showbones_temp[player_name]["togglehud"] == "on" then
         showbones.hide_hud(player_name)
         showbones.show_hud(player_name)
      end
   else                                            -- not dug by owner
      if showbones.is_joined_player(showbones_owner) then -- owner is online
         local player = minetest.get_player_by_name(showbones_owner) -- switch to owner player
         local player_name = player:get_player_name()
         showbones.clear_bones_pos(player_name, pos)                                                   
         showbones.chat_notify(showbones_owner, bones_breaker) -- tell owner they've been stolen from. random
            if showbones_temp[player_name]["togglehud"] == "on" then  -- online owner has showbones waypoints active. Need to reset
               showbones.hide_hud(player_name)
               showbones.show_hud(player_name)
            end
      else                                         -- owner is not online. Remove pos and save for him.       
         showbones.clear_bones_pos(showbones_owner, pos)
         showbones.save_player_table(showbones_owner)
      end
   end
end

function showbones.save_player_table(player_name)
	showbones_temp[player_name]["hud"] = nil
	showbones_temp[player_name]["togglehud"] = nil
   showbones.db_save(showbones_temp)
   showbones_temp[player_name] = nil               -- unset showbones_temp player to save memory.
   if not showbones_temp[player_name] then
      print("[" .. showbones.modname .. "] Saved " .. player_name .. "'s data, and cleared from memory.")
   end
end
---------------------------------------------
-- CALLBACKS --------------------------------
---------------------------------------------
minetest.register_on_joinplayer(function(player)
   local player_name = player:get_player_name()
	showbones_temp[player_name] = showbones.get_player_table(player_name)
end)

minetest.register_on_leaveplayer(function(player)  -- unset "togglehud", "hud" and save in db
	local player_name = player:get_player_name()
   showbones.save_player_table(player_name)
end)

minetest.register_on_shutdown(function()
	for id in pairs(showbones_temp) do
	   showbones_temp[id]["hud"] = nil
	   showbones_temp[id]["togglehud"] = nil
	end
	   showbones.db_save(showbones_temp)
	   print("[" .. showbones.modname .. "] Server shutting down, saved " .. showbones.modname .. " all player(s) data to db file.")
	   showbones_temp = nil
end)

minetest.register_on_dieplayer(function(player)
   local player_name = player:get_player_name()
	if minetest.setting_getbool("creative_mode") then -- in creative, no chance of bones, bail
		return
	end
	
	local pos = player:getpos()
	pos.x = math.floor(pos.x+0.5)
	pos.y = math.floor(pos.y+0.5)
	pos.z = math.floor(pos.z+0.5)
	
	pos = showbones.announce_bones(pos, player_name)
	
	if pos then	
	   showbones.hide_hud(player_name)              -- turn off hud or waypoints will be out of sync	
      showbones_temp[player_name] = showbones.update_bones_locations(pos, player_name)
   end


end)

local function is_owner(pos, name)                 -- need for below bones:bones on_punch override. Copied from bones:bones
	local owner = minetest.get_meta(pos):get_string("owner")
	if owner == "" or owner == name or minetest.check_player_privs(name, "protection_bypass") then
		return true
	end
	return false
end

minetest.override_item("bones:bones", {            -- almost all on_punch copied from bones:bones for override.
	on_punch = function(pos, node, player)
		if(not is_owner(pos, player:get_player_name())) then
			return
		end
		
		if(minetest.get_meta(pos):get_string("infotext") == "") then
			return
		end
		
		local inv = minetest.get_meta(pos):get_inventory()
		local player_inv = player:get_inventory()
		local has_space = true
		
		for i=1,inv:get_size("main") do
			local stk = inv:get_stack("main", i)
			if player_inv:room_for_item("main", stk) then
				inv:set_stack("main", i, nil)
				player_inv:add_item("main", stk)
			else
				has_space = false
				break
			end
		end
		
		-- remove bones if player emptied them
		if has_space then
			if player_inv:room_for_item("main", {name = "bones:bones"}) then
				player_inv:add_item("main", {name = "bones:bones"})
			else
				minetest.add_item(pos,"bones:bones")
			end
		   showbones.bones_removed(pos, player)   -- only thing added to this override.
			minetest.remove_node(pos)
		end
	end,
})
