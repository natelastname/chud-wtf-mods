if minetest.settings:get_bool('sdwalls_use_moreblocks_bricks', true) then
    local register = sdwalls.register
    local counter = 0

    local nodes = {
        'moreblocks:grey_bricks',
        'moreblocks:iron_stone_bricks',
        'moreblocks:cactus_brick',
        'moreblocks:coal_stone_bricks'
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
