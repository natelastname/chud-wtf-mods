if minetest.settings:get_bool('sdwalls_use_hades_trees_wood', false) then
    local register = sdwalls.register
    local counter = 0

    local nodes = {
        'hades_trees:colwood_black',
        'hades_trees:colwood_blue',
        'hades_trees:colwood_brown',
        'hades_trees:colwood_cyan',
        'hades_trees:colwood_dark_green',
        'hades_trees:colwood_dark_grey',
        'hades_trees:colwood_green',
        'hades_trees:colwood_grey',
        'hades_trees:colwood_magenta',
        'hades_trees:colwood_orange',
        'hades_trees:colwood_pink',
        'hades_trees:colwood_red',
        'hades_trees:colwood_violet',
        'hades_trees:colwood_white',
        'hades_trees:colwood_yellow',
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
