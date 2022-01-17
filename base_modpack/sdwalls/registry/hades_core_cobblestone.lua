if minetest.settings:get_bool('sdwalls_use_hades_core_cobblestone', true) then
    local register = sdwalls.register
    local counter = 0

    local nodes = {
        'hades_core:cobble',
        'hades_core:mossycobble',
        'hades_core:cobble_baked',
        'hades_core:cobble_sandstone',
        'hades_core:cobble_sandstone_volcanic',
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
