local S = simple_protection.translator

local commands = {}

function simple_protection.register_subcommand(name, func)
	if commands[name] then
		minetest.log("info", "[simple_protection] Overwriting chat command " .. name)
	end

	assert(#name:split(" ") == 1, "Invalid name")
	assert(type(func) == "function")

	commands[name] = func
end

--[[

chat_send(S("Information about this area"), "/area show")
chat_send(S("View of surrounding areas"), "/area radar")
chat_send(S("(Un)share one area"), "/area (un)share <name>")
chat_send(S("(Un)share all areas"), "/area (un)shareall <name>")
if simple_protection.area_list or privs.simple_protection then
   chat_send(S("List claimed areas"), "/area list [<name>]")
end
chat_send(S("Unclaim this area"), "/area unclaim")
if privs.server then
   chat_send(S("Delete all areas of a player"), "/area delete <name>")
end

]]--

function simple_protection.show(name)
   local player = minetest.get_player_by_name(name)
   local player_pos = player:get_pos()
   local data = simple_protection.get_claim(player_pos)

   minetest.add_entity(simple_protection.get_center(player_pos), "simple_protection:marker")
   local minp, maxp = simple_protection.get_area_bounds(player_pos)
   minetest.chat_send_player(name, S("Vertical from Y @1 to @2",
				     tostring(minp.y), tostring(maxp.y)))

   if not data then
      if simple_protection.underground_limit and minp.y < simple_protection.underground_limit then
	 return true, S("Area status: @1", S("Not claimable"))
      end
      return true, S("Area status: @1", S("Unowned (!)"))
   end

   minetest.chat_send_player(name, S("Area status: @1", S("Owned by @1", data.owner)))
   local text = ""
   for i, player in ipairs(data.shared) do
      text = text..player..", "
   end
   local shared = simple_protection.share[data.owner]
   if shared then
      for i, player in ipairs(shared) do
	 text = text..player.."*, "
      end
   end

   if text ~= "" then
      return true, S("Players with access: @1", text)
   end
end

local function check_ownership(name)
	local player = minetest.get_player_by_name(name)
	local data, index = simple_protection.get_claim(player:get_pos())
	if not data then
		return false, S("This area is not claimed yet.")
	end
	local priv = minetest.check_player_privs(name, {simple_protection=true})
	if name ~= data.owner and not priv then
		return false, S("You do not own this area.")
	end
	return true, data, index
end

local function table_erase(t, e)
	if not t or not e then
		return false
	end
	local removed = false
	for i, v in ipairs(t) do
		if v == e then
			table.remove(t, i)
			removed = true
		end
	end
	return removed
end

simple_protection.register_subcommand("share", function(name, param)
	if not param or name == param then
		return false, S("No player name given.")
	end
	if not minetest.builtin_auth_handler.get_auth(param) and param ~= "*all" then
		return false, S("Unknown player.")
	end
	local success, data, index = check_ownership(name)
	if not success then
		return success, data
	end

	if simple_protection.is_shared(name, param) then
		return true, S("@1 already has access to all your areas.", param)
	end

	if simple_protection.is_shared(data, param) then
		return true, S("@1 already has access to this area.", param)
	end
	table.insert(data.shared, param)
	simple_protection.set_claim(data, index)

	if minetest.get_player_by_name(param) then
		minetest.chat_send_player(param, S("@1 shared an area with you.", name))
	end
	return true, S("@1 has now access to this area.", param)
end)

simple_protection.register_subcommand("unshare", function(name, param)
	if not param or name == param or param == "" then
		return false, S("No player name given.")
	end
	local success, data, index = check_ownership(name)
	if not success then
		return success, data
	end
	if not simple_protection.is_shared(data, param) then
		return true, S("That player has no access to this area.")
	end
	table_erase(data.shared, param)
	simple_protection.set_claim(data, index)

	if minetest.get_player_by_name(param) then
		minetest.chat_send_player(param, S("@1 unshared an area with you.", name))
	end
	return true, S("@1 has no longer access to this area.", param)
end)

simple_protection.register_subcommand("shareall", function(name, param)
	if not param or name == param or param == "" then
		return false, S("No player name given.")
	end
	if not minetest.builtin_auth_handler.get_auth(param) then
		if param == "*all" then
			return false, S("You can not share all your areas with everybody.")
		end
		return false, S("Unknown player.")
	end

	if simple_protection.is_shared(name, param) then
		return true, S("@1 already has now access to all your areas.", param)
	end
	if not shared then
		simple_protection.share[name] = {}
	end
	table.insert(simple_protection.share[name], param)
	simple_protection.save_share_db()

	if minetest.get_player_by_name(param) then
		minetest.chat_send_player(param, S("@1 shared all areas with you.", name))
	end
	return true, S("@1 has now access to all your areas.", param)
end)

simple_protection.register_subcommand("unshareall", function(name, param)
	if not param or name == param or param == "" then
		return false, S("No player name given.")
	end
	local removed = false
	local shared = simple_protection.share[name]
	if table_erase(shared, param) then
		removed = true
		simple_protection.save_share_db()
	end

	-- Unshare each single claim
	local claims = simple_protection.get_player_claims(name)
	for index, data in pairs(claims) do
		if table_erase(data.shared, param) then
			removed = true
		end
	end
	if not removed then
		return false, S("@1 does not have access to any of your areas.", param)
	end
	simple_protection.update_claims(claims)
	if minetest.get_player_by_name(param) then
		minetest.chat_send_player(param, S("@1 unshared all areas with you.", name))
	end
	return true, S("@1 has no longer access to your areas.", param)
end)

function simple_protection.claim(name)
   local player = minetest.get_player_by_name(name)
   local pos = player:get_pos()
   if pos == nil then
      minetest.chat_send_player(name, "Unknown error.")
      return
   end
   
   if simple_protection.old_is_protected(pos, name) then
      minetest.chat_send_player(name,
				S("This area is already protected by an other protection mod."))
      return
   end
   if simple_protection.underground_limit then
      local minp, maxp = simple_protection.get_area_bounds(pos)
      if minp.y < simple_protection.underground_limit then
	 minetest.chat_send_player(name,
				   S("You can not claim areas below @1.",
				     simple_protection.underground_limit .. "m"))
	 return
      end
   end
   local data, index = simple_protection.get_claim(pos)
   if data then
      minetest.chat_send_player(name,
				S("This area is already owned by: @1", data.owner))
      return
   end
   
   -- Count number of claims for this user
   local claims_max = simple_protection.max_claims
   
   if minetest.check_player_privs(name, {simple_protection=true}) then
      -- Why...
      claims_max = claims_max * 2
   end

   local claims, count = simple_protection.get_player_claims(name)
   if count >= claims_max then
      minetest.chat_send_player(name,
				S("You can not claim any further areas: Limit (@1) reached.",
				  tostring(claims_max)))
      return
   end
   simple_protection.update_claims({
	 [index] = {owner=name, shared={}}
   })

   minetest.add_entity(simple_protection.get_center(pos), "simple_protection:marker")
   minetest.chat_send_player(name, S("Congratulations! You now own this area."))
   return itemstack
end


function simple_protection.unclaim(name)
   local success, data, index = check_ownership(name)
   if not success then
      minetest.chat_send_player(name, data)
      return success
   end
   if simple_protection.claim_return and name == data.owner then
      local player = minetest.get_player_by_name(name)
   end
   simple_protection.set_claim(nil, index)
   minetest.chat_send_player(name, S("This area is unowned now."))

   return true
end

-- Unclaim all land of a given player. "delete_self" is a misnomer.
function simple_protection.delete_self(name)
   local removed = {}
   if simple_protection.share[name] then
      simple_protection.share[name] = nil
      table.insert(removed, S("Globally shared areas"))
      simple_protection.save_share_db()
   end

   -- Delete all claims
   local claims, count = simple_protection.get_player_claims(name)
   for index in pairs(claims) do
      claims[index] = false
   end
   simple_protection.update_claims(claims)

   if count > 0 then
      table.insert(removed, S("@1 claimed area(s)", tostring(count)))
   end

   if #removed == 0 then
      return false, S("@1 does not own any claimed areas.", param)
   end
   return true, S("Removed")..": "..table.concat(removed, ", ")

end


simple_protection.register_subcommand("delete", function(name, param)
	if not param or name == param or param == "" then
		return false, S("No player name given.")
	end
	if not minetest.check_player_privs(name, {server=true}) then
		return false, S("Missing privilege: @1", "server")
	end

	local removed = {}
	if simple_protection.share[param] then
		simple_protection.share[param] = nil
		table.insert(removed, S("Globally shared areas"))
		simple_protection.save_share_db()
	end

	-- Delete all claims
	local claims, count = simple_protection.get_player_claims(param)
	for index in pairs(claims) do
		claims[index] = false
	end
	simple_protection.update_claims(claims)

	if count > 0 then
		table.insert(removed, S("@1 claimed area(s)", tostring(count)))
	end

	if #removed == 0 then
		return false, S("@1 does not own any claimed areas.", param)
	end
	return true, S("Removed")..": "..table.concat(removed, ", ")
end)


-- List the claims of the given player's faction.  
function simple_protection.list(name)
   local list = {}
   local width = simple_protection.claim_size
   local height = simple_protection.claim_height
   local claims = simple_protection.get_player_claims(name)
   for index in pairs(claims) do
      -- TODO: Add database-specific function to convert the index to a position
      local abs_pos = minetest.string_to_pos(index)
      table.insert(list, string.format("%5i,%5i,%5i",
				       abs_pos.x * width + (width / 2),
				       abs_pos.y * height - simple_protection.start_underground + (height / 2),
				       abs_pos.z * width + (width / 2)
      ))
   end
   local text = S("Listing all areas of @1. Amount: @2", name, tostring(#list))
   minetest.chat_send_player(name, text.."\n"..table.concat(list, "\n"))
end
