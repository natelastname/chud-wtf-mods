-- server_announce/init.lua
--

local started = false
local http_api = minetest.request_http_api()

local function on_response(response)
   -- TODO: Set started to true if the response is not 4xx
   --if response.code >= 500 or response.code < 400 then
   --   started = true
   --end
   started = true 
   print("Response:")
   print(dump(response))
end

local function itoa(x)
   return tostring(math.floor(x))
end


local function sendAnnounce(client_names)
   local server = {}
   local action = ""
   if started == true then
      action = "update"
   else
      action = "start"
   end
   -- Required fields
   server["action"]       = action
   server["clients"]      = itoa(#client_names)
   server["clients_max"]  = minetest.settings:get("max_users")
   server["uptime"]       = itoa(minetest.get_server_uptime())
   server["game_time"]    = itoa(minetest.get_gametime() or 0)
   server["version"]      = minetest.get_version().string
   server["gameid"]       = "minetest"
   server["name"]         = minetest.settings:get("server_name")
   server["description"]  = minetest.settings:get("server_description")
   -- Optional fields
   server["port"]         = minetest.settings:get("port")
   --server["address"]      = minetest.settings:get("server_address")
   server["address"]      = "134.122.6.68"
   server["url"]          = minetest.settings:get("server_url")
   server["creative"]     = minetest.settings:get("creative_mode")
   server["damage"]       = minetest.settings:get("enable_damage")
   server["password"]     = minetest.settings:get("disallow_empty_password")
   server["pvp"]          = minetest.settings:get("enable_pvp")
   server["clients_list"] = client_names
   server["privs"]        = minetest.settings:get("default_privs")
   
   local fetch_request = {}
   fetch_request.url = minetest.settings:get("serverlist_url").."/announce"

   local json = minetest.write_json(server)
   fetch_request.post_data = {}
   fetch_request.post_data["json"] = json
   fetch_request.multipart = true
   
   print("Sending request:")
   print(json)
   
   http_api.fetch(fetch_request, on_response)
end

local function update_serverlist()

   if http_api == nil then
      minetest.log("error", "Mod server_announce needs to be added to secure.http_mods")

   end

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

	   if param == "start" then
	      started = false
	   end
	   minetest.log("info", "Announcing server...")
	   update_serverlist()
	   if true then
	      return
	   end
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
