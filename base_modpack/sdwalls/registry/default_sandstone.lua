if minetest.settings:get_bool('sdwalls_use_default_sandstone', true) then
    local register = sdwalls.register
    local counter = 0


    local nodes = {
        'default:sandstonebrick',
        'default:desert_sandstone_brick',
        'default:silver_sandstone_brick'
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
