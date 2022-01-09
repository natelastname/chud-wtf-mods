--[[
File: protection.lua

Protection callback handler
Node placement checks
Claim Stick item definition
]]

local sp = simple_protection
local S = sp.translator

local function notify_player(pos, player_name)
	local data = sp.get_claim(pos)
	if not data and sp.claim_to_dig then
		minetest.chat_send_player(player_name, S("Please claim this area to modify it."))
	elseif not data then
		-- Access restricted by another protection mod. Not my job.
		return
	else
		minetest.chat_send_player(player_name, S("Area owned by: @1", data.owner))
	end
end

sp.old_is_protected = minetest.is_protected
minetest.is_protected = function(pos, player_name)
   if sp.can_access(pos, player_name) then
      return sp.old_is_protected(pos, player_name)
   end
   return true
end

minetest.register_on_protection_violation(notify_player)

minetest.register_entity("simple_protection:marker",{
	initial_properties = {
		hp_max = 1,
		visual = "wielditem",
		visual_size = {x=1.0/1.5,y=1.0/1.5},
		physical = false,
		textures = {"simple_protection:mark"},
	},
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(10, function()
			self.object:remove()
		end)
	end,
})

-- hacky - I'm not a regular node!
local size = sp.claim_size / 2
minetest.register_node("simple_protection:mark", {
	tiles = {"simple_protection_marker.png"},
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	drop = "",
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- sides
			{-size-.5, -size-.5, -size-.5,	-size-.5, size+.5,  size-.5},
			{-size-.5, -size-.5,  size-.5,	 size-.5, size+.5,  size-.5},
			{ size-.5, -size-.5, -size-.5,	 size-.5, size+.5,  size-.5},
			{-size-.5, -size-.5, -size-.5,	 size-.5, size+.5, -size-.5},
		},
	},
})
