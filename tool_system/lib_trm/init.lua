
lib_trm = {}
lib_trm.name = "lib_trm"
lib_trm.ver_max = 0
lib_trm.ver_min = 1
lib_trm.ver_rev = 0
lib_trm.ver_str = lib_trm.ver_max .. "." .. lib_trm.ver_min .. "." .. lib_trm.ver_rev
lib_trm.authorship = "lisacvuk, davidthecreator, shadmordre"
lib_trm.license = "LGLv2.1"
lib_trm.copyright = "2019"
lib_trm.path_mod = minetest.get_modpath(minetest.get_current_modname())
lib_trm.path_world = minetest.get_worldpath()

lib_trm.intllib = minetest.settings:get_bool("lib_trm_engine_translation") or false

local S
local NS
if not lib_trm.intllib then
   if minetest.get_modpath("intllib") then
      S = intllib.Getter()
   else
      -- S = function(s) return s end
      -- internationalization boilerplate
      S, NS = dofile(lib_trm.path_mod.."/intllib.lua")
   end
else
   S = minetest.get_translator(lib_trm.name)
end

minetest.log(S("[MOD] lib_trm:  Loading..."))
minetest.log(S("[MOD] lib_trm:  Version:") .. S(lib_trm.ver_str))
minetest.log(S("[MOD] lib_trm:  Legal Info: Copyright ") .. S(lib_trm.copyright) .. " " .. S(lib_trm.authorship) .. "")
minetest.log(S("[MOD] lib_trm:  License: ") .. S(lib_trm.license) .. "")

--minetest.log("[MOD] lib_trm:  Loading...")
--minetest.log("[MOD] lib_trm:  Version:" .. lib_trm.ver_str)
--minetest.log("[MOD] lib_trm:  Legal Info: Copyright " .. lib_trm.copyright .. " " ..lib_trm.authorship) .. "")
--minetest.log("[MOD] lib_trm:  License: " .. lib_trm.license .. "")


dofile(lib_trm.path_mod.."/lib_trm_toolcap_modifier.lua")

dofile(lib_trm.path_mod.."/lib_trm_tool_ranks.lua")


minetest.register_on_mods_loaded(function()
      for node_name, node_def in pairs(minetest.registered_tools) do
	 if node_name and node_name ~= "" then
	    if node_def then
	       if not node_def.original_description then
		  local node_desc = node_def.description
		  minetest.override_item(node_name, {
					    original_description = node_desc,
					    description = toolranks.create_description(node_desc, 0, 1),
					    --description = node_desc,
					    after_use = toolranks.new_afteruse,
		  })
	       end
	    end
	 end
      end
end)



minetest.log(S("[MOD] lib_trm:  Successfully loaded."))




























