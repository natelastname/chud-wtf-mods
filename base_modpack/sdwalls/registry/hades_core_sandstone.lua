if minetest.settings:get_bool('sdwalls_use_hades_core_sandstone', true) then
    local register = sdwalls.register
    local counter = 0

    local nodes = {
        'hades_core:sandstone_volcanic_brick',
        'hades_core:sandstone_brick',
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
