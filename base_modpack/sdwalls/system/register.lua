--Localize needed functions
local additional_groups = sdwalls.additional_groups
local update_according_to_neighbors = sdwalls.update_according_to_neighbors
local replace = sdwalls.replace
local S = sdwalls.translator
local connect_to_base = minetest.settings:get_bool('sdwalls_connect_to_base')
local connect_to_self = minetest.settings:get_bool('sdwalls_connect_to_self')


-- Set up needed node boxes
local nodebox = {
    fixed_pillar = { -4/16, -8/16, -4/16,  4/16, 8/16,  4/16 },
    fixed_wall = {   -3/16, -8/16, -3/16,  3/16, 8/16,  3/16 },
    right = {         3/16, -8/16, -3/16,  8/16, 8/16,  3/16 },
    left = {         -8/16, -8/16, -3/16, -3/16, 8/16,  3/16 },
    front = {        -3/16, -8/16, -8/16,  3/16, 8/16, -3/16 },
    back = {         -3/16, -8/16,  3/16,  3/16, 8/16,  8/16 },
    -- Additionally needed nodeboxes
    pillar_disconnected_top = {
        { -2/16, 10/16, -2/16, 2/16, 12/16, 2/16 },
        { -3/16, 9/16, -3/16, 3/16, 11/16, 3/16  },
        { -4/16, 8/16, -4/16, 4/16, 10/16, 4/16  },
    },
    pillar_disconnected_bottom = {
        { -6/16, -8/16, -6/16, 6/16, -7/16, 6/16 },
        { -5/16, -7/16, -5/16, 5/16, -6/16, 5/16 }
    }
}


-- Register nodes
--
-- Registers the walls and pillars basing on the provided node.
--
-- wall_definition = {
--   name = 'My Cool Wall Name',  -- name for the wall/pillar
--   groups = {},                 -- additional groups
--   pillar = {},                 -- configuration for the pillar
--   wall = {},                   -- configuration for the wall
-- }
--
-- The tables for `pillar` and for `wall` can contain one or all of those
-- entries for overriding the base node’s attributes.
--
-- {
--     tiles = tiles_definition_table,  -- override tiles
--     sounds = SimpleSoundSpec,        -- override sounds
--     light_source = 1                 -- override light source setting
-- }
--
-- @see Minetest’s lua_api.txt for SimpleSoundSpec and tiles definition table
--
-- @param id The node ID to register a wall for/from
-- @param wall_definition A table as described
-- @return bool,table Successful registration and the registered node IDs
sdwalls.register = function (id, definition)
    local node = minetest.registered_nodes[id]
    if node == nil then return false,{wall=false, pillar=false} end
    local wd = (definition or {}).wall or {}
    local pd = (definition or {}).pillar or {}

    local node_id = node.name
    local node_id_sanitized = node.name:gsub(':', '_')

    local name = S('@1 Wall', node.description)
    local connections = {}
    local target_id_pillar = 'sdwalls:pillar_'..node_id_sanitized
    local target_id_wall = 'sdwalls:wall_'..node_id_sanitized

    local groups = (definition or {}).groups
    local node_groups = additional_groups(node.groups, (groups or {}))

    if minetest.is_yes(connect_to_base) or connect_to_base == nil then
        table.insert(connections, node.name)
    end

    if minetest.is_yes(connect_to_self) then
        table.insert(connections, target_id_pillar)
        table.insert(connections, target_id_wall)
    else
        table.insert(connections, 'group:sdwalls')
    end

    minetest.register_node(':'..target_id_pillar, {
        description = (definition or {}).name or name,
        tiles = pd.tiles or node.tiles,
        sounds = pd.sounds or node.sounds,
        groups = additional_groups(node_groups, {
            sdwalls = 1,
        }),
        connects_to = connections,
        paramtype = 'light',
        drawtype = 'nodebox',
        light_source = pd.light_source or node.light_source,
        after_place_node = function(pos) update_according_to_neighbors(pos) end,
        after_destruct = function(pos) update_according_to_neighbors(pos) end,
        on_punch = function (pos, node, player) replace(pos, node, player) end,
        node_box = {
            type = 'connected',
            fixed = nodebox.fixed_pillar,
            connect_right = nodebox.right,
            connect_left = nodebox.left,
            connect_front = nodebox.front,
            connect_back = nodebox.back,
            disconnected_top = nodebox.pillar_disconnected_top,
            disconnected_bottom = nodebox.pillar_disconnected_bottom
        },
        selection_box = {
            type = 'connected',
            fixed = nodebox.fixed_pillar,
            connect_right = nodebox.right,
            connect_left = nodebox.left,
            connect_front = nodebox.front,
            connect_back = nodebox.back
        }
    })

    minetest.register_node(':'..target_id_wall, {
        description = (definition or {}).name or name,
        tiles = wd.tiles or node.tiles,
        sounds = wd.sounds or node.sounds,
        groups = additional_groups(node_groups, {
            sdwalls = 1,
            not_in_creative_inventory = 1
        }),
        connects_to = connections,
        paramtype = 'light',
        drawtype = 'nodebox',
        light_source = wd.light_source or node.light_source,
        after_place_node = function(pos) update_according_to_neighbors(pos) end,
        after_destruct = function(pos) update_according_to_neighbors(pos) end,
        on_punch = function (pos, node, player) replace(pos, node, player) end,
        drop = target_id_pillar..' 1',
        node_box = {
            type = 'connected',
            fixed = nodebox.fixed_wall,
            connect_right = nodebox.right,
            connect_left = nodebox.left,
            connect_front = nodebox.front,
            connect_back = nodebox.back,
        },
        selection_box = {
            type = 'connected',
            fixed = nodebox.fixed_wall,
            connect_right = nodebox.right,
            connect_left = nodebox.left,
            connect_front = nodebox.front,
            connect_back = nodebox.back
        }
    })

    minetest.register_craft({
        output = target_id_pillar..' 5',
        recipe = {
            {'', '', '' },
            {node_id, node_id, '' },
            {node_id, node_id, node_id }
        }
    })

    minetest.register_craft({
        output = node_id..' 1',
        type = 'shapeless',
        recipe = { target_id_pillar }
    })

    return true, { wall = target_id_wall, pillar = target_id_pillar }
end

