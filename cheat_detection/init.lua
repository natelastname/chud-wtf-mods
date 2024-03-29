--   cheat_detection: A minetest addon that will check/target/ban players for potential abnormal behavior caused commonly by hacked clients
--   Copyright (C) 2020  Genshin <emperor_genshin@hotmail.com>
--
--   This program is free software: you can redistribute it and/or modify
--   it under the terms of the GNU Affero General Public License as
--   published by the Free Software Foundation, either version 3 of the
--   License, or (at your option) any later version.
--
--   This program is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU Affero General Public License for more details.
--
--   You should have received a copy of the GNU Affero General Public License
--   along with this program.  If not, see <http://www.gnu.org/licenses/>.

--TODO: Test further to find additional false positives
cheat_detection = {}
local enable_automod = minetest.settings:get('enable_cheat_detection_automod') or false
local automod_type = minetest.settings:get('cheat_detection_automod_type') or "ban"
local automod_reason = minetest.settings:get('cheat_detection_automod_reason') or "Excessive Cheating Attempts"
-- The minimum amount of seconds between cheat detection checks on any individual player.
-- This mod also takes into account the player's latency. 
local cheat_detection_step = tonumber(minetest.settings:get("cheat_detection_step")) or 1/30
-- How long to grant immunity when a player logs in, respawns, teleports, etc.
local immunity_period_secs = 2.0
-- unused
local server_step = tonumber(minetest.settings:get("dedicated_server_step")) or 1/60
local patience_meter = 5
local server_host = minetest.settings:get("name") or ""
local detection_list = {}
local debug_hud_list = {}


-- Debug mode:
-- Allow staff members to trigger cheat detection, log a lot more info
local debug_mode = false

-- Test mode:
-- Broadcast cheat accusations in global chat with a cooldown of chat_interval seconds between
-- accusations of the same player. Do not punish anybody for anything.
local test_mode = true
local chat_interval = 15
local chat_cooldown = ctf_core.init_cooldowns()


if enable_automod and type(enable_automod) == "string" then
   if enable_automod == "true" then
      enable_automod = true
   elseif enable_automod == "false" then
      enable_automod = false
   end
end

-- I don't understand the point of this function
local function get_velocity_as_whole_interger(player, dir)
   local result = nil
   local velocity = player:get_velocity()
   local vel_x, vel_z = nil 
   if dir == "horizontal" then
      local speed = nil
      vel_x = math.floor(velocity.x)
      vel_z = math.floor(velocity.z)
      if vel_x < 0 and vel_z >= 0 then
	 vel_x = math.abs(vel_x)
      elseif vel_z < 0 and vel_x >= 0 then
	 vel_z = math.abs(vel_x)
      end
      if vel_x > vel_z then
	 speed = math.abs(vel_x)
      elseif vel_z > vel_x then
	 speed = math.abs(vel_z)
      elseif vel_x == vel_z then
	 speed = math.abs(vel_x or vel_z)
      end
      result = speed
   elseif dir == "vertical" then
      result = velocity.y
   end
   return result
end


--Patch for unknown block detection skipping, we really just need to get useful properties only anyway
local function verify_node(node)
   local def = minetest.registered_nodes[node.name]
   --Is it a undefined block? if so generate some properties for it
   if def == nil then
      def = {walkable = true, drawtype = "normal"}
   end
   return def
end


local function add_tracker(player)
   local name = player:get_player_name()
   if not detection_list[name] then
      -- A lot of this crap is unused, or otherwise should be deleted.
      detection_list[name] = {
	 suspicion = "None",
	 prev_pos = {x = 0, y = 0, z = 0},
	 prev_velocity = {x = 0, y = 0, z = 0},
	 strikes = 0,
	 patience_cooldown = 2,
	 automod_triggers = 0,
	 instant_punch_time = 0,
	 unhold_sneak_time = 0,
	 liquid_walk_time = 0,        
	 flight_time = 0,
	 falling_stops_time = 0,
	 node_clipping_time = 0, 
	 flying = false,
	 alert_sent = false,
	 falling = false,
	 killaura = false,
	 fast_dig = false,
	 instant_break = false,
	 abnormal_range = false,
	 killaura_check = false,
      }
   end
end


local function update_tracker_info(player, list)
   local name = player:get_player_name()
   if detection_list[name] then
      detection_list[name] = list
   end
end


local function remove_tracker(player)
   local name = player:get_player_name()
   if detection_list[name] then
      detection_list[name] = nil
   end
end


local function get_tracker(player)
   local name = player:get_player_name()
   local result = nil
   if detection_list[name] then
      result = detection_list[name]
   end
   return result
end


local function cast_ray_under_player(player, range, objects, liquids)
   local pos = player:get_pos()
   
   objects = objects or false
   liquids = liquids or false

   --Raycast stuff.
   local ray_start = vector.add({x = pos.x, y = pos.y - 1, z = pos.z}, {x=0, y=0, z=0})
   local ray_modif = vector.multiply({x = 0, y = -0.9, z = 0}, range) --point ray down
   local ray_end = vector.add(ray_start, ray_modif)
   local ray = minetest.raycast(ray_start, ray_end, objects, liquids)
   local object = ray:next()

   --Skip player's collision
   if object and object.type == "object" and object.ref == player then
      object = ray:next()
   end

   return object
end


local function cast_ray_under_pos(pos, range, objects, liquids)
   objects = objects or false
   liquids = liquids or false

   --Raycast stuff.
   local ray_start = vector.add({x = pos.x, y = pos.y - 0.1, z = pos.z}, {x=0, y=0, z=0})
   local ray_modif = vector.multiply({x = 0, y = -0.9, z = 0}, range) --point ray down
   local ray_end = vector.add(ray_start, ray_modif)
   local ray = minetest.raycast(ray_start, ray_end, objects, liquids)
   local object = ray:next()
   --

   return object
end



--check if player has a obstacle underneath him (Returns a boolean)
local function check_obstacle_found_under(player, range)
   local result = false 
   local object = cast_ray_under_player(player, range, true, true)
   if object and object.type then
      result = true
   end
   return result
end


--check if player has a obstacle underneath him and get their properties (Returns a table of properties, if failed returns nil)
local function get_obstacle_found_under(player, range)
   local result = nil
   local object = cast_ray_under_player(player, range, true, true)
   if object and object.type then
      if object.type == "node" then
	 local node = minetest.get_node(object.under)
	 --We need to make sure this raycast does not grab air as it's final target
	 if node  then
	    local def = verify_node(node)
	    result = {name = node.name, type = "node", def = def}
	 end
      elseif object.type == "object" and object.ref and not(object.ref:is_player() or object.ref == player) then
	 local entity = object.ref:get_luaentity()
	 result = {name = entity.name, type = "entity", def = entity}
      end
   end

   return result
end


--check if position has a node underneath it and get their properties (Returns a table of properties, if failed returns nil)
local function get_node_under_ray(pos, range)
   local result = nil
   local object = cast_ray_under_pos(pos, range, false, true)
   if object and object.type and object.type == "node" then
      local node = minetest.get_node(object.under)
      --We need to make sure this raycast does not grab air as it's final target
      if node then
	 local def = verify_node(node)
	 result = def
      end
   end
   return result
end


--needed for flight check and jesus walk checks to prevent false positives by entity collision
local function check_if_entity_under(pos)
   local entities = minetest.get_objects_inside_radius({x = pos.x, y = pos.y, z = pos.z}, 1)
   local result = false
   --look for physical objects only (TODO: convert method to raycast)
   for _,entity in pairs(entities) do
      if not entity:is_player() and entity:get_luaentity().physical == true then
	 result = true
	 break
      end
   end
   return result
end

local function is_door(node_name)
   if node_name == nil then
      return false
   end
   if doors.registered_doors[node_name] ~= nil or doors.registered_trapdoors[node_name] ~= nil then
      return true
   end
   return false
end


local function check_player_is_inside_nodes(player)
   local pos = player:get_pos()

   local node_top = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
   local node_bottom = minetest.get_node(pos)
   local result = false

   if node_top and node_bottom then

      if is_door(node_top.name) or is_door(node_bottom.name)then
	 return false
      end

      node_top = minetest.registered_nodes[node_top.name]
      node_bottom = minetest.registered_nodes[node_bottom.name]
      if node_top and node_top.walkable and node_bottom and node_bottom.walkable then
	 result = true
      end
   end    

   return result
end


local function check_player_is_swimming(player)
   local pos = player:get_pos()
   
   local node_top = minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z})
   local node_bottom = minetest.get_node(pos)
   local result = false

   if node_top and node_bottom then
      node_top = minetest.registered_nodes[node_top.name]
      node_bottom = minetest.registered_nodes[node_bottom.name]
      if type(node_top) == "table" 
	 and type(node_bottom) == "table" 
	 and (node_top.drawtype == "liquid" 
		 or node_top.drawtype == "flowingliquid" 
		 or node_bottom.drawtype == "liquid" 
	      or node_bottom.drawtype == "flowingliquid") then 
	    result = true
      end
   end    

   return result
end

local function is_solid_node_under(pos, max_height)
   local result = false
   local y_steps = 0
   local found = false
   while max_height > y_steps do
      local node = minetest.get_node_or_nil({x = pos.x, y = pos.y - y_steps, z = pos.z})
      if node == nil then
	 -- unloaded block
	 return true
      end
      if node.name == nil or minetest.registered_nodes[node.name] == nil then
	 -- unknown block
	 return true
      end      
      if minetest.registered_nodes[node.name].drawtype ~= "airlike" and minetest.registered_nodes[node.name].walkable == true then
	 -- Some solid block
	 return true
      end
      y_steps = y_steps + 1
   end
   return result 
end



--Check surroundings for nodes in a 3x3 block order (Returns specified node property value if successful, if not then it returns nil)
local function check_surrounding_for_nodes(height, pos)
   local result = false
   local scan_tries = 8

   --TODO: false positive - unable to grab slabs, fences and banners with raycast, make standard get_node() failsafe [Sneak Key] *facepalm...

   --Only scan for nearby nodes by 3x3 blocks
   while scan_tries > 0 do
      local new_pos = nil
      local node = nil

      if scan_tries == 8 then
	 new_pos = {x = pos.x, y = pos.y + height, z = pos.z - 1}
	 node = is_solid_node_under(new_pos, 4)
      elseif scan_tries == 7 then
	 new_pos = {x = pos.x - 1, y = pos.y + height, z = pos.z - 1}
	 node = is_solid_node_under(new_pos, 4)
      elseif scan_tries == 6 then
	 new_pos = {x = pos.x + 1, y = pos.y + height, z = pos.z + 1}
	 node = is_solid_node_under(new_pos, 4)
      elseif scan_tries == 5 then
	 new_pos = {x = pos.x - 1, y = pos.y + height, z = pos.z}
	 node = is_solid_node_under(new_pos, 4)
      elseif scan_tries == 4 then
	 new_pos = {x = pos.x - 1, y = pos.y + height, z = pos.z + 1}
	 node = is_solid_node_under(new_pos, 4)
      elseif scan_tries == 3 then
	 new_pos = {x = pos.x + 1, y = pos.y + height, z = pos.z - 1}
	 node = is_solid_node_under(new_pos, 4)
      elseif scan_tries == 2 then
	 new_pos = {x = pos.x + 1, y = pos.y + height, z = pos.z}
	 node = is_solid_node_under(new_pos, 4)
      elseif scan_tries == 1 then
	 new_pos = {x = pos.x, y = pos.y + height, z = pos.z + 1}
	 node = is_solid_node_under(new_pos, 4)
      end

      --print(tostring(scan_tries)..") "..tostring(node))

      if node == true then
	 result = node
	 break
      end

      scan_tries = scan_tries - 1
   end

   return result
end


--Alert staff if goon is pulling hacks out of his own ass
local function send_alert_to_serverstaff(suspect, suspicion)

   if test_mode and not chat_cooldown:get(suspect) then
      minetest.chat_send_all("[CHEAT DETECTION (beta)]: ".. tostring(suspect) .. " accused of '" .. tostring(suspicion) .. "'")
      chat_cooldown:set(suspect, chat_interval)
      return
   end

   if true then
      return
   end

   
   local players = minetest.get_connected_players()
   for _,player in pairs(players) do
      local name = player:get_player_name()

      local info = get_tracker(player)
      local is_staff = minetest.check_player_privs(name, {ban=true})

      --Do not spam these alerts more than once per accusation since staff can get annoyed by accusation spam
      if is_staff == true then
	 minetest.chat_send_player(name, minetest.colorize("#ffbd14" ,"*** "..os.date("%X")..":[CHEAT DETECTION]: Player ")..minetest.colorize("#FFFFFF", tostring(suspect))..minetest.colorize("#ffbd14" ," may be performing ")..minetest.colorize("#FF0004", tostring(suspicion))..minetest.colorize("#ffbd14" ," hacks!"))
      end
   end
end

local function check_if_forced_flying(player, info, pos, velocity, avg_rtt)
   
   if velocity.y ~= 0 then
      info.hover_time = 0
      return false
   end

   -- This is the boundary of a chunk, the player could be standing on an unloaded block.
   -- Of course, this means that hackers could fly around along the boundaries of chunks,
   -- but that's still better than being able to fly around anywhere
   if math.round(pos.y) % 16 == 0 then
      return false
   end
   
   local name = player:get_player_name()
   if debug_mode == false and minetest.check_player_privs(name, {fly=true}) == true then
      info.hover_time = 0	    
      return false
   end
   
   local node_under = is_solid_node_under(pos, 1)
   
   if node_under == true then
      info.hover_time = 0
      return false
   end

   -- type can be node, entity
   local object_under = get_obstacle_found_under(player, 1)
   
   if object_under ~= nil and (object_under.type == "node" or object_under.type == "entity") then
      -- Is there an entity or node directly below the player?
      info.hover_time = 0

      return false
   end

   -- We have found no obvious node or entity below the player, yet they are not falling.
   -- Perform a more comprehensive check.
   if debug_mode then
      print("================================================")
      minetest.log("action", "[CHEAT DETECTION]: Player "..name.." triggered the Hover Check.")
   end
   
   local near_nodes = check_surrounding_for_nodes(1, pos)
   
   if near_nodes == true then
      if debug_mode then
	 minetest.log("action", "[CHEAT DETECTION]: Hover check of player "..name.." failed, they are near some solid node.")
      end
      info.hover_time = 0
      return false
   end
   
   local near_ent = check_if_entity_under(pos)

   if near_ent == true then
      -- They are near something solid.
      if debug_mode then
	 minetest.log("action", "[CHEAT DETECTION]: Hover check of player "..name.." failed, they are near some solid entity.")
      end
      info.hover_time = 0
      return false
   end

   -- This is based on the code Minetest uses internally to detect whether the player is climbing or not.
   -- It is not perfect. Sometimes triggers when exiting a ladder at a particular angle.
   -- This could be addressed by giving the player immunity on the first position recorded after exiting a ladder,
   -- but for now we can simply trust that the delay is sufficiently large.
   
   
   local pp1 = vector.add(pos, vector.new({x=0, y=0.5, z=0}))
   local pp2 = vector.add(pos, vector.new({x=0, y=-0.2, z=0}))

   if false and debug_mode then
      print("exact pos:" .. vector.to_string(pos))
      print("          " .. vector.to_string(vector.round(pos)))
      print("      pp1:" .. vector.to_string(vector.round(pp1)))
      print("          " .. vector.to_string(vector.round(pp1)))
      print("      pp2:" .. vector.to_string(vector.round(pp2)))
      print("          " .. vector.to_string(vector.round(pp2)))
   end
   
   local climbable1 = minetest.registered_nodes[minetest.get_node(pp1).name].climbable or false
   local climbable2 = minetest.registered_nodes[minetest.get_node(pp2).name].climbable or false

  
   if climbable1 or climbable2 then
      minetest.log("action", "[CHEAT DETECTION]: Hover check of player "..name.." failed, they are on a climbable node.")
      info.hover_time = 0
      return false
   end
   
   -- Prevent/skip false positive to trigger by unloaded block lag when falling too fast or when a object is
   -- underneath or if he/she just had logged in to spare them from a aggressive detection
   -- TODO: Test what happens when standing on an unloaded block, currently this doesn't work
   local was_falling = info.falling or false
   if was_falling == true then
      info.hover_time = 0
      minetest.log("action", "[CHEAT DETECTION]: Player "..name.." was falling down but was halted by unloaded blocks, No suspicious activity found.")
      return false
   end
   
   info.hover_time = info.hover_time + 1
   local delay = tonumber(patience_meter + avg_rtt)

   if debug_mode then
      minetest.log("warning", "[CHEAT DETECTION]: Player "..name.." is detected as hovering ("..tostring(info.hover_time).."/"..tostring(delay)..")")
   end
   
   if info.hover_time >= delay then
      minetest.log("warning", "[CHEAT DETECTION]: Player "..name.." is detected as hovering!")
      info.strikes = 3  
      return true
   end

   return true

end


local function check_if_forced_noclipping(player, info, pos, velocity, avg_rtt)
   local result = false
   
   if pos == nil then
      return false
   end
   
   --local current_pos = vector.round(pos)
   local current_pos = pos
   local name = player:get_player_name()
   local delay = tonumber(patience_meter + avg_rtt)
   local can_noclip = minetest.check_player_privs(name, {noclip=true})
   local inside_nodes = check_player_is_inside_nodes(player)

   if debug_mode == false and can_noclip == true then
      return false
   end
   
   if inside_nodes == false then
      -- The player is not stuck
      info.is_stuck = false
      info.prev_stuck_pos = nil
      return false
   end

   if info.prev_stuck_pos == nil then
      -- The player is stuck, but no previous position is stored
      info.is_stuck = true
      info.prev_stuck_pos = current_pos
      return false
   end

   -- The distance between the position the player was first recorded being stuck
   -- and the current position.
   local d = 0
   if info.prev_stuck_pos ~= nil then
      d = vector.length(vector.subtract(current_pos, info.prev_stuck_pos))
   end
   
   if debug_mode == true and info.prev_stuck_pos ~= nil then
      print("========== Possible noclip: ==========")
      print("is stuck:" .. tostring(info.stuck))
      print("Previous stuck pos: " .. vector.to_string(info.prev_stuck_pos))
      print("       Current pos:" .. vector.to_string(current_pos))
      print("          Distance:" .. tostring(d))
   end  
   
   -- The farthest distance it is conceivably possible to move while being stuck legitimately
   -- is hard to determine. It is definately atleast 1.01. Sqrt(3) (the length of the diagonal
   -- of a unit cube) seems to be a GENEROUS upper bound. 
   if info.stuck and d > math.sqrt(3) then
      minetest.log("warning", "[CHEAT DETECTION]: Player "..name.." is clipping through solid nodes while moving without noclip privileges. Server has marked this as suspicious activity!")
      player:set_pos(info.prev_stuck_pos)
      info.strikes = 3
      return true
   end
   -- If here, the player is stuck but they haven't moved too far.
   
   info.stuck = true

   return false
   
end


local function check_if_forced_fast(player, info)
   local result = false

   local aux_pressed = player:get_player_control().aux1

   --if player is not pressing sprint key, skip this check
   if aux_pressed == false then
      return result
   end

   local name = player:get_player_name()
   local current_speed = get_velocity_as_whole_interger(player, "horizontal")
   local min_speed = tonumber(minetest.settings:get("movement_speed_fast")) or 20
   local detection_fast_speed = nil
   local can_fast = minetest.check_player_privs(name, {fast=true})
   local speed_mod = tonumber(player:get_physics_override().speed)
   local f = math.floor

   --This is needed to determine if user is speeding, subtract 1 for fast speed accuracy
   min_speed = math.floor(speed_mod * min_speed) 
   detection_fast_speed = math.floor(min_speed - 1) 

   if can_fast == false and (current_speed == min_speed or current_speed == detection_fast_speed) then
      minetest.log("warning", "[CHEAT DETECTION]: Player "..name.."\'s speed went past the server\'s max speed without fast privs too many times. Server has marked this as suspicious activity!")
      result = true
   end

   return result
end


local function check_if_jesus_walking(player, info, pos, velocity, avg_rtt)
   local result = false

   local name = player:get_player_name()
   local obstacle_under = get_obstacle_found_under(player, 1)
   local node_under = "not found"
   local swimming = check_player_is_swimming(player)
   local sneak_hold = player:get_player_control().sneak or false
   local delay = tonumber(patience_meter + avg_rtt)

   if obstacle_under and obstacle_under.type == "node" and obstacle_under.def.drawtype then
      node_under = obstacle_under.def.drawtype
   end

   --If someone is able to stand still on a liquid type node, then they are clearly walking on water
   if swimming == false and (node_under == "liquid" or node_under == "flowingliquid") and pos.y == info.prev_pos.y and velocity.y == 0 and sneak_hold == false then
      local object_under = check_if_entity_under(pos)
      if object_under == false then
	 info.node_clipping_time = info.node_clipping_time + 1
	 info.liquid_walk_time = info.liquid_walk_time + 1
	 --print("Liquid Walk Time: "..tostring(info.liquid_walk_time)) 
      end
   else
      info.liquid_walk_time = 0
   end

   --Get triggered if the player has been constantly walking on water for far too long
   if info.liquid_walk_time >= delay then
      minetest.log("warning", "[CHEAT DETECTION]: Player "..name.." is litteraly standing on water, Server has marked this as suspicious activity!")
      info.strikes = 3  
      result = true
   end


   return result
end

-- This function doesn't really verify suspicious behavior, but
-- rather registers a strike once the suspicious behavior has already
-- been verified.
local function verify_suspicious_behavior(info, suspicion, avg_rtt)
   local timer_step = tonumber(cheat_detection_step + avg_rtt)  
   minetest.after(timer_step, function() 
		     info.strikes = info.strikes + 1
   end)
   --Don't go past 3 strikes
   if info.strikes >= 3 then
      info.suspicion = suspicion
      info.strikes = 3
      info.patience_cooldown = 2
   end
end


-- player, info, pos, velocity, pinfo.avg_rtt
local function on_after_rtt(pname)   
   local player = minetest.get_player_by_name(pname)
   
   if player == nil then
      return
   end

   local info = get_tracker(player)
   local pos = player:get_pos()
   local velocity = player:get_velocity()

   if pos == nil or velocity == nil then
      return
   end

   local pinfo = minetest.get_player_information(pname) 

   -- Turned off for being broken
   --local is_jesus_walking = check_if_jesus_walking(player, info, pos, velocity, pinfo.avg_rtt)
   local is_jesus_walking = false
   local is_force_noclipping = check_if_forced_noclipping(player, info, pos, velocity, pinfo.avg_rtt)
   --local is_force_fast = check_if_forced_fast(player, info)
   local is_force_fast = false
   local is_force_flying = check_if_forced_flying(player, info, pos, velocity, pinfo.avg_rtt)
   
   --Hmm, I sense suspicious activity in this sector... [Killaura]
   if info.killaura == true then
      verify_suspicious_behavior(info, "Killaura", pinfo.avg_rtt)
      info.killaura_check = false
      info.killaura = false

      --Hmm, I sense suspicious activity in this sector... [Unlimited Range]
   elseif info.abnormal_range == true then
      verify_suspicious_behavior(info, "Unlimited Range", pinfo.avg_rtt)
      info.abnormal_range = false

      --Hmm, I sense suspicious activity in this sector... [Instant Break]
   elseif info.instant_break == true then
      verify_suspicious_behavior(info, "Instant Node Break", pinfo.avg_rtt)
      info.instant_break = false

      --Hmm, I sense suspicious activity in this sector... [Fast Dig]
   elseif info.fast_dig == true then
      verify_suspicious_behavior(info, "Fast Dig", pinfo.avg_rtt)
      info.fast_dig = false

      --Hmm, I sense suspicious activity in this sector... [Walk on Water Hacks]
   elseif is_jesus_walking == true then
      verify_suspicious_behavior(info, "Jesus Walk", pinfo.avg_rtt)

      --Hmm, I sense suspicious activity in this sector... [Noclip Hacks]
   elseif is_force_noclipping == true then
      verify_suspicious_behavior(info, "Forced Noclip", pinfo.avg_rtt)

      --Hmm, I sense suspicious activity in this sector... [Fast Hacks]
   elseif is_force_fast == true then
      verify_suspicious_behavior(info, "Forced Fast", pinfo.avg_rtt)

      --Hmm, I sense suspicious activity in this sector... [Fly Hacks]
   elseif is_force_flying == true then
      verify_suspicious_behavior(info, "Forced Fly", pinfo.avg_rtt)
      --So far so good, nothing to see here (Reset timers and strikes)
   else
      info.patience_cooldown = info.patience_cooldown - 1
      if info.patience_cooldown < 1 then
	 info.automod_triggers = 0
	 info.patience_cooldown = 2
      end
   end

   --Send Warning after 3 strikes, then reset. Following up with patience meter to drop
   if info.strikes == 3 and info.suspicion ~= "None" then
      send_alert_to_serverstaff(pname, info.suspicion)

      if info.alert_sent == false then
	 minetest.log("warning", "[CHEAT DETECTION]: Player "..pname.." have been flagged for " .. info.suspicion)
	 --minetest.chat_send_player(pname, minetest.colorize("#ffbd14" ,"*** "..os.date("%X")..":[CHEAT DETECTION]: You have been flagged by the Server for possibly using a Hacked Client. Our server staff have been alerted!"))
	 info.alert_sent = true
      end

      if enable_automod == true then
	 local delay = tonumber(patience_meter + pinfo.avg_rtt)
	 info.automod_triggers = info.automod_triggers + 1

	 if info.automod_triggers >= delay then
	    smite = true
	 end
      end
      info.strikes = 0
   elseif info.strikes == 3 and info.suspicion == "None" then
      info.strikes = 0
   end

   --I ran out of patience, please for the love of god Let me BAN this sneaky little twat NOW!!!
   if smite and enable_automod == true then
      info.automod_triggers = 0

      if automod_type == "kick" then

	 minetest.log("action", "[CHEAT DETECTION]: Server has kicked "..pname.." for performing continuous abnormal behaviors while in-game.")
	 minetest.kick_player(pname, "Cheat Detection: "..automod_reason)

      elseif automod_type == "ban" then
	 
	 minetest.log("action", "[CHEAT DETECTION]: Server has banned "..pname.." for performing continuous abnormal behaviors while in-game.")
	 minetest.ban_player(pname)
	 
      end

   end

   info.prev_velocity = velocity
   info.prev_pos = pos
   update_tracker_info(player, info)

end

-- This is a neccessary wrapper to handle errors resulting from players logging off.
-- Otherwise, some random player:get_pos() call could fail within handle_cheat_detection
-- when a player leaves the game and cause the whole server to crash.
-- It is also not a big deal if this fails in production, because it will automatically
-- be called again. 
local function run_cheat_detect(func, pname)
   local status, err = pcall(func, pname)
   if status == false then
      minetest.log("warning", "[CHEAT DETECTION] Error, hopefully this was caused by a player leaving the game:")
			minetest.log("warning", "[CHEAT DETECTION]".. err)
   end
end

local cheat_detect_cooldown = ctf_core.init_cooldowns()
local immunity_cooldown = ctf_core.init_cooldowns()

function cheat_detection.grant_temp_immunity(player)
   if player == nil or not player.get_player_name then
      return
   end
   
   local pname = player:get_player_name()
   if pname ~= nil then
      minetest.log("action", "[CHEAT DETECTION] Player " .. pname .. " granted temporary immunity.")
   end
   immunity_cooldown:set(player, immunity_period_secs)
end


--Enable Server Anti-Cheat System if Player Manager is Present, keep an eye out for suspicious activity
local function handle_cheat_detection()
   local players = minetest.get_connected_players()
   for _, player in pairs(players) do
      
      local pname = player:get_player_name()
      local is_superuser = minetest.check_player_privs(pname, {server=true})
      local pinfo = minetest.get_player_information(pname)
      local info = get_tracker(player)
      local smite = false
      local skip_player = false
      
      if pname == server_host or is_superuser then
	 skip_player = true
      end
      
      if debug_mode then
	 skip_player = false
      end

      if immunity_cooldown:get(player) then
	 -- The player has temporary immunity (after login, after teleporting, when they respawn)
	 skip_player = true
      end
      
      if cheat_detect_cooldown:get(player) then
	 -- There is no need to cheat detect a player more than once
	 -- in one avg_rtt interval.
	 skip_player = true
      end
      
      if pinfo and info and skip_player == false then
	 cheat_detect_cooldown:set(player, pinfo.avg_rtt)
	 run_cheat_detect(on_after_rtt, pname)
      end
      
   end
   minetest.after(cheat_detection_step, handle_cheat_detection)
end


minetest.register_on_mods_loaded(function()
      handle_cheat_detection()
end)

minetest.register_on_leaveplayer(function(player)
      remove_tracker(player)
end)

minetest.register_on_joinplayer(function(player)
      add_tracker(player)
      cheat_detection.grant_temp_immunity(player)
end)

-- Handle the built-in Minetest cheat detection
minetest.register_on_cheat(function(player, cheat)
      local info = get_tracker(player)

      --Skip shenanigain check if player is punched, this is for knockback exceptions
      
      local name = player:get_player_name()
      local pinfo = minetest.get_player_information(name)
      local accusation = nil

      if pinfo == nil then
	 return
      end
      
      if name == nil then
	 return
      end

      -- Problem: this can be triggered by ranged weapons
      if cheat.type == "interacted_too_far" then
	 accusation = "unlimitedrange"
	 send_alert_to_serverstaff(name, accusation)
	 return
      end
      -- This can be triggered too easily, appears to be broken
      if cheat.type == "dug_unbreakable" then
	 accusation = "instantbreak" 
	 --send_alert_to_serverstaff(name, accusation)
	 return
      end
      if cheat.type == "dug_too_fast" then
	 accusation = "fastdig"
	 send_alert_to_serverstaff(name, accusation)
	 return
      end
end)

function detect_killaura(player, hitter, punchtime)   
   local name = nil
   local info2 = nil
   local pinfo = nil
   local delay = nil
   
   if hitter:is_player() then
      name = hitter:get_player_name()
      info2 = get_tracker(hitter)
      pinfo = minetest.get_player_information(name)
      delay = tonumber(patience_meter + pinfo.avg_rtt - 1)
   end

   --killaura detection (Needs to be redesigned)
   if info2 and punchtime <= 0 then
      info2.killaura_check = true
      info2.instant_punch_time = info2.instant_punch_time + 1
      --Confirm killaura behavior if player instantly punched a player too many times
      if info2.instant_punch_time > delay then
	 info2.killaura = true
	 minetest.log("warning", "[CHEAT DETECTION]: Player "..name.." is instantly punching players too many times. Server has marked this as suspicious activity!")    
      end    
   elseif info2 and punchtime > 0 then
      info2.instant_punch_time = 0 
   end

end


minetest.register_on_respawnplayer(function(player)
      -- Respawning is like teleporting - it can trigger fly detection.
      cheat_detection.grant_temp_immunity(player)
end)

minetest.register_on_punchplayer(function(player, hitter, punchtime) 
      detect_killaura(player, hitter, punchtime)
end)

minetest.register_on_mods_loaded(function()
      minetest.log("info", "[CHEAT DETECTION]: ====== Anticheat loaded ======")
      mobs:register_on_mob_punched(function(ent, hitter, tflp, tool_capabilities, dir)
	    detect_killaura(ent, hitter, tflp)
      end)
end)
