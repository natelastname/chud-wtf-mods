-- Replaces (swaps) a node at the given position
--
-- This function is to be used in the node registration’s on_punch.
sdwalls.replace = function (pos, node, player)
    if not player:is_player() then return end

    local wielded = player:get_wielded_item():get_name():gsub('_.*', '')
    local current_type = node.name:gsub('_.*', '')

    if wielded == 'sdwalls:pillar' then
        if current_type == 'sdwalls:wall' then
            minetest.swap_node(pos, {
                name = node.name:gsub('sdwalls:wall', 'sdwalls:pillar')
            })
        elseif current_type == 'sdwalls:pillar' then
            minetest.swap_node(pos, {
                name = node.name:gsub('sdwalls:pillar', 'sdwalls:wall')
            })
        end
    end
end


-- Get the type of a node
--
-- Returns either `pillar` or `wall` if the node at `pos` is an SDWalls pillar
-- or SDWalls wall. In all other cases `nil` is returned.
--
-- @param own_pos The reference node’s own position
-- @param pos     The position iof the node to check
-- @return mixed Either boolean `false` if no SDWalls wall/pillar or the name
--               of the node if paramenter `name` is boolean true.
sdwalls.get_type = function (pos)
    local node_type =  minetest.get_node(pos).name:gsub('_.*', '')

    if node_type == 'sdwalls:wall' then node_type = 'wall' end
    if node_type == 'sdwalls:pillar' then node_type = 'pillar' end
    if node_type == 'wall' or node_type == 'pillar' then return node_type end
end


-- Add additional groups
--
-- Returns the provided group table with the new groups and their values added
-- to that table.
--
-- @param groups     The Groups table to use as base
-- @param new_groups A table of new groups in the same format as the groups
--                   table defined by the Minetest API.
-- @return table     The new groups table
sdwalls.additional_groups = function (groups, new_groups)
    local target = table.copy(groups)
    for name,value in pairs(new_groups) do
        target[name] = value
    end
    return target
end
