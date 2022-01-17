-- Set mod-related things
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local syspath = modpath..DIR_DELIM..'system'..DIR_DELIM
local regpath = modpath..DIR_DELIM..'registry'..DIR_DELIM


-- Localize Minetest functions
local get_dir_list = minetest.get_dir_list
local settings = minetest.settings
local log = minetest.log


-- Initiante global table
sdwalls = {
    translator = minetest.get_translator(modname)
}


-- Load functions into the global table
dofile(syspath..'helper_functions.lua')
dofile(syspath..'update_according_to_neighbors.lua')
dofile(syspath..'register.lua')


-- APIfy global table and log mod loading state
local register = sdwalls.register
sdwalls = { register = register }
log('action', '[sdwalls] Mod loaded')


-- Register built-in nodes
minetest.register_on_mods_loaded(function()
    if settings:get_bool('sdwalls_built_in_groups', true) then
        local message = 'Registered walls from built-in support: '
        local counter = 0
        for _,regfile in pairs(get_dir_list(regpath, false)) do
            local count_up = dofile(regpath..DIR_DELIM..regfile) or 0
            counter = counter + count_up
        end
        log('info', '[sdwalls] '..message..counter)
    end
end)
