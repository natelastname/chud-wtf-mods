if minetest.settings:get_bool('sdwalls_use_morebricks_nodes', true) then
    local register = sdwalls.register
    local counter = 0
    local nodes = {}

    for id,def in pairs(minetest.registered_nodes) do
        if def.mod_origin == 'morebricks' and def.drawtype == 'normal' then
            table.insert(nodes, id)
        end
    end

    for _,node in pairs(nodes) do
        local ok = register(node)
        if ok == true then counter = counter + 1 end
    end

    return counter
end
