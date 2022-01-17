if minetest.settings:get_bool('sdwalls_use_hades_core_bricks_col', true) then
    local register = sdwalls.register
    local counter = 0

    local nodes = {
        'hades_core:brick_black',
        'hades_core:brick_blue',
        'hades_core:brick_brown',
        'hades_core:brick_cyan',
        'hades_core:brick_dark_green',
        'hades_core:brick_dark_grey',
        'hades_core:brick_green',
        'hades_core:brick_gray',
        'hades_core:brick_magenta',
        'hades_core:brick_orange',
        'hades_core:brick_pink',
        'hades_core:brick_red',
        'hades_core:brick_violet',
        'hades_core:brick_white',
        'hades_core:brick_yellow',
    }

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
