if minetest.settings:get_bool('sdwalls_use_default_wood', false) then
    local register = sdwalls.register
    local counter = 0

    local nodes = {
        'default:acacia_tree', 'default:acacia_wood',
        'default:aspen_tree',  'default:aspen_wood',
        'default:jungletree',  'default:junglewood',
        'default:pine_tree',   'default:pine_wood',
        'default:tree',        'default:wood'
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
