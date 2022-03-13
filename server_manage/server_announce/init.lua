-- server_announce/init.lua
--

local started = false
local http_api = minetest.request_http_api()

local function on_response(response)
   -- TODO: Set started to true if the response is not 4xx
   started = true
   print("Response:")
   print(dump(response))
end

local function sendAnnounce(client_names)
   local server = {}
   if started == true then
      server["action"] = "update"
   else
      server["action"] = "start"
   end
   server["port"]         = tonumber(minetest.setting_get("port"))
   server["address"]      = minetest.setting_get("server_address")
   server["name"]         = minetest.setting_get("server_name")
   server["description"]  = minetest.setting_get("server_description")
   server["version"]      = minetest.get_version().string
   server["url"]          = minetest.setting_get("server_url")
   server["creative"]     = minetest.setting_getbool("creative_mode")
   server["damage"]       = minetest.setting_getbool("enable_damage")
   server["password"]     = minetest.setting_getbool("disallow_empty_password")
   server["pvp"]          = minetest.setting_getbool("enable_pvp")
   server["uptime"]       = minetest.get_server_uptime()
   server["game_time"]    = minetest.get_gametime()
   server["clients"]      = #client_names
   server["clients_max"]  = tonumber(minetest.setting_get("max_users"))
   server["clients_list"] = client_names
   server["gameid"]       = "minetest"
   server["privs"]        = minetest.setting_get("default_privs")
   
   local fetch_request = {}
   local json = minetest.write_json(server)
   fetch_request.url = minetest.setting_get("serverlist_url").."/announce"
   fetch_request.post_data = {}
   fetch_request.post_data["json"] = json
   fetch_request.multipart = true
   print(dump(server))
   
   http_api.fetch(fetch_request, on_response)
end

local function update_serverlist()
   local names = {}
   for _, player in ipairs(minetest.get_connected_players()) do
      local name = player:get_player_name()
      table.insert(names, name)
   end
   sendAnnounce(names)
end



minetest.register_chatcommand("announce", {
	params = "",
	description = "Announce the server to servers.minetest.net",
	privs = {server=true},
	func = function(name, param)
	   minetest.log("info", "Announcing server...")
	   local status, err = pcall(update_serverlist(), nil)
	   if status == true then
	      minetest.log("info", "Request completed.")
	   else
	      minetest.log("info", "Request failed:")
	      print(dump(err))
	   end
	end,
})
minetest.register_chatcommand("crash", {
	params = "",
	description = "Intentionally crash the server",
	privs = {server=true},
	func = function(name, param)
	   minetest.log("error", "Intentionally crashing the server.")
	   local crash = nil
	   crash:crash_server()
	end,
})
