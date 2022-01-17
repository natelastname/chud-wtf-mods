if minetest.settings:get_bool('sdwalls_use_default_cobblestone', true) then
    local register = sdwalls.register
    local counter = 0

    local nodes = {
        'default:cobble',
        'default:mossycobble',
        'default:desert_cobble'
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
