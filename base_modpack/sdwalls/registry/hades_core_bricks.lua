if minetest.settings:get_bool('sdwalls_use_hades_core_bricks', true) then
    local register = sdwalls.register
    local counter = 0

    local nodes = {
        'hades_core:brick',
        'hades_core:cactus_brick',
        'hades_core:chondrite_brick',
        'hades_core:essexite_brick',
        'hades_core:marble_brick',
        'hades_core:obsidianbrick',
        'hades_core:stonebrick',
        'hades_core:stonebrick_baked',
        'hades_core:tuff_baked_brick',
        'hades_core:tuff_brick'
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
