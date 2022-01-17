if minetest.settings:get_bool('sdwalls_use_hades_moreblocks_bricks', true) then
    local register = sdwalls.register
    local counter = 0

    local nodes = {
        'hades_moreblocks:grey_bricks',
        'hades_moreblocks:iron_stone_bricks',
        'hades_moreblocks:coal_stone_bricks'
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
