-- Localize needed functions
local get_type = sdwalls.get_type


-- Update neighbors according to the placed/removed thing
--
-- Positions according to testing environment
--
--       z+1
--
--  x-1   N   x+1
--
--       z-1
--
-- When to set a pillar
--
-- o = irrelevant node
-- x = relevant node (wall or pillar)
-- N = current position
--
--                  x       o       o       x
-- Corners        o N x   o N x   x N o   x N o
--                  o       x       x       o
--
--                  x       x       o       x
-- T-junctions    x N x   o N x   x N x   x N o
--                  o       x       x       x
--
--                  x       o       o       o
-- Wall ends      o N o   o N x   o N o   x N o
--                  o       o       x       o
--
--                  o
-- Standalone     o N o
--                  o
--
--                  x
-- Surrounded     x N x
--                  x
--
-- Identifiers are clock-wise single-line representations of the above
-- 2D representations:
--
-- xxoo = top right corner
-- oxxo = bottom right corner
-- ooxx = bottom left corner
-- xoox = top left corner
--
-- xxox = top junction
-- xxxo = right junctions
-- oxxx = bottom junction
-- xoxx = left junction
--
-- xooo = top end
-- oxoo = right end
-- ooxo = bottom end
-- xooo = left end
--
-- oooo = standalone
-- xxxx = surrounded
--
-- @param pos the position of the node to use as reference
-- @return void
sdwalls.update_according_to_neighbors = function (pos)

    local to_check_neighbors = {
        own_position = pos,
        z_plus_1 = { x = pos.x, y = pos.y, z = pos.z+1 },
        x_plus_1 = { x = pos.x+1, y = pos.y, z = pos.z },
        z_minus_1 = { x = pos.x, y = pos.y, z = pos.z-1 },
        x_minus_1 = { x = pos.x-1, y = pos.y, z = pos.z }
    }

    for nominal,npos in pairs(to_check_neighbors) do
        local current_name = minetest.get_node(npos).name

        local ref = {
            zp1 = get_type({ x = npos.x,   y = npos.y, z = npos.z+1 }),
            xp1 = get_type({ x = npos.x+1, y = npos.y, z = npos.z   }),
            zm1 = get_type({ x = npos.x,   y = npos.y, z = npos.z-1 }),
            xm1 = get_type({ x = npos.x-1, y = npos.y, z = npos.z   })
        }

        -- When the node is a corner node
        local xxoo =     ref.zp1 and     ref.xp1 and not ref.zm1 and not ref.xm1
        local oxxo = not ref.zp1 and     ref.xp1 and     ref.zm1 and not ref.xm1
        local ooxx = not ref.zp1 and not ref.xp1 and     ref.zm1 and     ref.xm1
        local xoox =     ref.zp1 and not ref.xp1 and not ref.zm1 and     ref.xm1
        local corners = xxoo or oxxo or ooxx or xoox

        -- When the node is in a T-junction
        local xxox =     ref.zp1 and     ref.xp1 and not ref.zm1 and     ref.xm1
        local xxxo =     ref.zp1 and     ref.xp1 and     ref.zm1 and not ref.xm1
        local oxxx = not ref.zp1 and     ref.xp1 and     ref.zm1 and     ref.xm1
        local xoxx =     ref.zp1 and not ref.xp1 and     ref.zm1 and     ref.xm1
        local tjunctions = xxox or xxxo or oxxx or xoxx

        -- When the node is at the wall’s end
        local xooo =     ref.zp1 and not ref.xp1 and not ref.zm1 and not ref.xm1
        local oxoo = not ref.zp1 and     ref.xp1 and not ref.zm1 and not ref.xm1
        local ooxo = not ref.zp1 and not ref.xp1 and     ref.zm1 and not ref.xm1
        local ooox = not ref.zp1 and not ref.xp1 and not ref.zm1 and     ref.xm1
        local wall_end = xooo or oxoo or ooxo or ooox

        -- Special cases (standalone and surrounded)
        local oooo = not ref.zp1 and not ref.xp1 and not ref.zm1 and not ref.xm1
        local xxxx =     ref.zp1 and     ref.xp1 and     ref.zm1 and     ref.xm1
        local special = oooo or xxxx

        -- Replace according to the “truth table” above
        local relevant_position = corners or tjunctions or wall_end or special
        local relevant_node = get_type(npos) and true or false
        local replacement = ''

        -- Set replacement according to the previous calculation
        if relevant_position then
            replacement = current_name:gsub('sdwalls:wall', 'sdwalls:pillar')
        else
            replacement = current_name:gsub('sdwalls:pillar', 'sdwalls:wall')
        end

        -- Replace the currently checked node if relevant
        if relevant_node then
            minetest.swap_node(npos, {
                name = replacement
            })
        end


    end
end
