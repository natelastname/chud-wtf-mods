if minetest.settings:get_bool('sdwalls_use_hades_trees_wood_col', false) then
    local register = sdwalls.register
    local counter = 0

    local nodes = {
        'hades_trees:birch_tree',   'hades_trees:cream_wood',
        'hades_trees:canvas_tree',  'hades_trees:colwood_uncolored',
        'hades_trees:charred_tree', 'hades_trees:charred_wood',
        'hades_trees:jungle_tree',  'hades_trees:jungle_wood',
        'hades_trees:orange_tree',  'hades_trees:lush_wood',
        'hades_trees:pale_tree',    'hades_trees:pale_wood',
        'hades_trees:tree',         'hades_trees:wood',
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
