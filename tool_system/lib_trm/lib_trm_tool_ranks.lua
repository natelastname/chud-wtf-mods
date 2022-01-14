local mod_storage = minetest.get_mod_storage()


if minetest.get_modpath("toolranks") then
	return
else
	toolranks = {}
end

--toolranks = {}

toolranks.colors = {
  grey = minetest.get_color_escape_sequence("#9d9d9d"),
  green = minetest.get_color_escape_sequence("#1eff00"),
  gold = minetest.get_color_escape_sequence("#ffdf00"),
  white = minetest.get_color_escape_sequence("#ffffff")
}

function toolranks.get_tool_type(description)
  if string.find(description, "Pickaxe") then
    return "pickaxe"
  elseif string.find(description, "Axe") then
    return "axe"
  elseif string.find(description, "Shovel") then
    return "shovel"
  elseif string.find(description, "Hoe") then
    return "hoe"
  else
    return "tool"
  end
end

function toolranks.create_description(name, uses, level)
  local description = name
  local tooltype    = toolranks.get_tool_type(description)

  local newdesc = toolranks.colors.green .. description .. "\n" ..
                  toolranks.colors.gold .. "Level " .. (level or 1) .. " " .. tooltype .. "\n" ..
                  toolranks.colors.grey .. "Nodes dug: " .. (uses or 0)		-- .. "\n" ..
		  -- name

  return newdesc
end

function toolranks.get_level(uses)
  if uses <= 200 then
    return 1
  elseif uses < 400 then
    return 2
  elseif uses < 1000 then
    return 3
  elseif uses < 2000 then
    return 4
  elseif uses < 3200 then
    return 5
  else
    return 6
  end
end

function toolranks.new_afteruse(itemstack, user, node, digparams)

	local itemmeta  = itemstack:get_meta() -- Metadata
	local t_mod = itemmeta:get_string("tmod")
	local itemdef   = itemstack:get_definition() -- Item Definition
	local itemdesc  = itemdef.original_description -- Original Description
	local t_modname = itemmeta:get_string("tmod_name") or ""
	--local modname_color = ""
	--local modname_text = ""
	local t_modstat = itemmeta:get_string("tmod_stat") or ""
	--local t_orgdesc = itemmeta:get_string("original_description") or ""
	local t_name    = ""
	local t_stat	= ""
	local dugnodes  = tonumber(itemmeta:get_string("dug")) or 0 -- Number of nodes dug
	local lastlevel = tonumber(itemmeta:get_string("lastlevel")) or 1 -- Level the tool had


	if t_modname ~= "" then
		local modname_color, modname_text = unpack(t_modname:split(",", true))
		
		t_name    = minetest.get_color_escape_sequence(modname_color) .. modname_text .. toolranks.colors.green .. itemdesc
	else
		t_name    = toolranks.colors.green .. itemdesc
	end


	if t_modstat ~= "" then
		local new_stats = t_modstat:split(";", true)
		for _, ns in pairs(new_stats) do

			local n_color, n_text = unpack(ns:split(",", true))

			--new_node_def.groups[g_name] = tonumber(g_val)
			t_stat	= t_stat .. minetest.get_color_escape_sequence(n_color) .. n_text
		end
	end

		--minetest.log("[MOD] lib_trm:  itemdesc..." .. itemdesc)
		--minetest.log("[MOD] lib_trm:  t_modname..." .. t_modname)
		--minetest.log("[MOD] lib_trm:  t_modstat..." .. t_modstat)
		--minetest.log("[MOD] lib_trm:  t_orgdesc..." .. t_orgdesc)

-- on the last dig
	local most_digs = mod_storage:get_int("most_digs") or 0
	local most_digs_user = mod_storage:get_string("most_digs_user") or 0
  
-- Only count nodes that spend the tool
	if(digparams.wear > 0) then
		dugnodes = dugnodes + 1
		itemmeta:set_string("dug", dugnodes)
	end

	if(dugnodes > most_digs) then

		most_digs = dugnodes
		if(most_digs_user ~= user:get_player_name()) then -- Avoid spam.

			most_digs_user = user:get_player_name()

			minetest.chat_send_all("Most used tool is now a " .. t_name .. toolranks.colors.white .. " owned by " .. user:get_player_name() .. " with " .. dugnodes .. " uses.")

		end

		mod_storage:set_int("most_digs", dugnodes)
		mod_storage:set_string("most_digs_user", user:get_player_name())

	end

	if(itemstack:get_wear() > 60135) then
		minetest.chat_send_player(user:get_player_name(), "Your tool is about to break!")
		minetest.sound_play("default_tool_breaks", {to_player = user:get_player_name(), gain = 2.0, })
	end


	local level = toolranks.get_level(dugnodes)
	if lastlevel < level then

		local levelup_text = "Your " .. t_name .. toolranks.colors.white .. " just leveled up!"

		minetest.sound_play("toolranks_levelup", {to_player = user:get_player_name(), gain = 2.0, })

		minetest.chat_send_player(user:get_player_name(), levelup_text)

		itemmeta:set_string("lastlevel", level)
	end


	local newdesc   = ""

	if t_stat ~= "" then
		newdesc   = toolranks.create_description(t_name, dugnodes, level) .. "\n" .. t_stat
	else
		newdesc   = toolranks.create_description(t_name, dugnodes, level)
	end

	itemmeta:set_string("description", newdesc)
	
	local wear = digparams.wear
	if level > 1 then
		wear = digparams.wear / (1 + level / 4)
	end

		--minetest.chat_send_all("wear="..wear.."Original wear: "..digparams.wear.." 1+level/4="..1+level/4)
		-- Uncomment for testing ^

	itemstack:add_wear(wear)

	return itemstack

end
