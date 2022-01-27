--[[                         .__               .__
         ____ ___  _________ |  |   ____  _____|__| ____   ____   ______
       _/ __ \\  \/  /\____ \|  |  /  _ \/  ___/  |/  _ \ /    \ /  ___/
       \  ___/ >    < |  |_> >  |_(  <_> )___ \|  (  <_> )   |  \\___ \
        \___  >__/\_ \|   __/|____/\____/____  >__|\____/|___|  /____  >
            \/      \/|__|                   \/               \/     \/

                         Explosion API mod for Minetest

    This mod adds a common API to generate ray-traced explosions in Minetest.
    Ray-traced explosion are more realistic than what is currently used to
    simulate explosions.  It allows different nodes to have different blast
    resistances, and will allow nodes with high blast resistance to absorb
    blasts, protecting weaker nodes or entities behind them.  This mod only
    exposes one function `explosions.explode' which is used to create
    explosions of various strengths and shapes.

    The computation-intensive parts of the mod has been optimized to allow for
    larger explosions and faster world updating.

    This mod was created by Elias Astrom <gitlab.com/ryvnf> and is released
    under the LGPL license.
--]]

explosions = {}

-- Saved sphere explosion shapes for various radiuses
local sphere_shapes = {}

-- Saved node definitions in table using cid-keys for faster look-up.
local node_defs = {}
local node_br = {}

-- Set to false to opt-out of flying nodes.
local flying_nodes = minetest.settings:get_bool("explosions_flying_nodes", false)

local AIR_CID = minetest.get_content_id('air')

function explosions.set_blastres(name, blastres)
   node_br[minetest.get_content_id(name)] = blastres
end

-- Calculate blast resistance for a node
--
-- If node has group `blast_resistance' use its value as the blast resistance,
-- otherwise calculate it from other node groups (like `crumbly',
-- `dig_immediate' and `level').
function explosions.get_blastres(name, def)
  if node_br[minetest.get_content_id(name)] then
    return node_br[minetest.get_content_id(name)]
  end
   
  if def and def.groups and def.groups.blast_resistance then
    return def.groups.blast_resistance
  end
  
  
  -- Each of the 4 levels of the block groups is assigned a level
  local instant_br = { [0] = math.huge, 25, 12.5, 6.25 }
  local oddly_br = { [0] = math.huge, 100, 75, 50 }
  local crumbly_br = { [0] = math.huge, 100, 75, 50 }
  local choppy_br = { [0] = math.huge, 100, 75, 50 }
  local snappy_br = { [0] = math.huge, 50, 25, 12.5 }
  local cracky_br = { [0] = math.huge, 200, 150, 100 }
  local liquid_br = { [0] = math.huge, 200, 100, 50 }
  -- Is it possible for nodes to have a level above 3?
  local level_mul = { [0] = 1, 1.5, 2.5, 5 }

  res = math.huge
  res = math.min(res, instant_br[minetest.get_item_group(name, 'dig_immediate')])
  res = math.min(res, oddly_br[
    minetest.get_item_group(name, 'oddly_breakable_by_hand')
  ])
  res = math.min(res, crumbly_br[minetest.get_item_group(name, 'crumbly')])
  res = math.min(res, choppy_br[minetest.get_item_group(name, 'choppy')])
  res = math.min(res, snappy_br[minetest.get_item_group(name, 'snappy')])
  res = math.min(res, cracky_br[minetest.get_item_group(name, 'cracky')])
  res = math.min(res, liquid_br[minetest.get_item_group(name, 'liquid')])
  res = res * level_mul[minetest.get_item_group(name, 'level')]

  -- nodes without definition (like "air") get 0 as blast resistance
  if res == math.huge then
    res = 0
  end

  return res
end

minetest.register_on_mods_loaded(function()
  -- Store node definitions by content ids to improve efficiency.
  for name, def in pairs(minetest.registered_nodes) do
    node_defs[minetest.get_content_id(name)] = def
    def.groups.blast_resistance = explosions.get_blastres(name, def)
    node_br[minetest.get_content_id(name)] = explosions.get_blastres(name)
  end
  setmetatable(node_defs, {})
end)

-- Compute the rays which make up a sphere with radius.  Returns a list of rays
-- which can be used to trace explosions.  This function is not efficient
-- (especially for larger radiuses), so the generated rays for various radiuses
-- should be cached and reused.
--
-- Should be possible to improve by using a midpoint circle algorithm multiple
-- times to create the sphere, currently uses more of a brute-force approach.
local function compute_sphere_rays(radius)
  local rays = {}
  local sphere = {}

  for y = -radius, radius do
    for z = -radius, radius do
      for x = -radius, 0, 1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for y = -radius, radius do
    for z = -radius, radius do
      for x = radius, 0, -1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for x = -radius, radius do
    for z = -radius, radius do
      for y = -radius, 0, 1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for x = -radius, radius do
    for z = -radius, radius do
      for y = radius, 0, -1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for x = -radius, radius do
    for y = -radius, radius do
      for z = -radius, 0, 1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for x = -radius, radius do
    for y = -radius, radius do
      for z = radius, 0, -1 do
        local d = x * x + y * y + z * z
        if d <= radius * radius then
          local pos = { x = x, y = y, z = z }
          sphere[minetest.hash_node_position(pos)] = pos
          break
        end
      end
    end
  end

  for _, pos in pairs(sphere) do
    rays[#rays + 1] = vector.normalize(pos)
  end

  return rays
end

-- Traces the rays of an explosion, and updates the environment.
--
-- Parameters:
--   pos - Where the rays in the explosion should start from
--   strength - The strength of each ray
--   raydirs - The directions for each ray
--   radius - The maximum distance each ray will go
--
-- Note that this function has been very optimized, it contains much code which
-- has been inlined to avoid function calls and unnecessary table creation,
-- which makes it around 66 % faster.
local function trace_explode(pos, strength, raydirs, radius)
  local vm = minetest.get_voxel_manip()

  -- We need node data that for all nodes within radius, plus one to do the
  -- flying node check.  In very rare cases we also need one extra radius.
  local emin, emax = vm:read_from_map(
    vector.subtract(pos, radius + 2),
    vector.add(pos, radius + 2))
  local emin_x = emin.x
  local emin_y = emin.y
  local emin_z = emin.z

  local ystride = (emax.x - emin_x + 1)
  local zstride = ystride * (emax.y - emin_y + 1)
  local pos_x = pos.x
  local pos_y = pos.y
  local pos_z = pos.z

  local area = VoxelArea:new {
    MinEdge = emin,
    MaxEdge = emax
  }
  local data = vm:get_data()
  local rnd = {}
  local callbacks = {}

  for i = 1, #raydirs do
    local rpos_x = pos.x
    local rpos_y = pos.y
    local rpos_z = pos.z
    local rdir_x = raydirs[i].x
    local rdir_y = raydirs[i].y
    local rdir_z = raydirs[i].z
    local rstr = strength

    for r = 0, radius do
      local npos_x = math.floor(rpos_x + 0.5)
      local npos_y = math.floor(rpos_y + 0.5)
      local npos_z = math.floor(rpos_z + 0.5)

      local ndir_x = npos_x - math.floor(pos.x)
      local ndir_y = npos_y - math.floor(pos.y)
      local ndir_z = npos_z - math.floor(pos.z)


      r = math.hypot(ndir_x, math.hypot(ndir_y, ndir_z))
      if r < 1 then
	 r = 1
      end

      
      local idx = (npos_z - emin_z) * zstride + (npos_y - emin_y) * ystride +
          npos_x - emin_x + 1

      local cid = data[idx]
      local def = node_defs[cid]
      local br = node_br[cid]
      local hash = (npos_z + 32768) * 65536 * 65536 +
          (npos_y + 32768) * 65536 +
          npos_x + 32768

      -- Every node gets a uniformly random value between one and two, this
      -- gets multiplied by the blast resistance.  This makes explosions
      -- unpredictable and makes them do damage to the environment proportional
      -- to the amount of TNTs in the blast.
      if not rnd[idx] then
        --rnd[idx] = math.random(1,2)
	 rnd[idx]=1
      end

      -- As the explosion expands, it will have more surface area, so the force
      -- on the blocks will be lower.  We simulate this by multiplying the
      -- blast resistance by a factor.  The formula for the surface area of a
      -- sphere is `pi r^2', so we use `r * r' as the factor.
      local res = br * r * r
      if false and res ~= 0 and rstr >= res* rnd[idx] then
	 print("-----------------------------------")
	 print("Block name:".. node_defs[cid].name)
	 print(" Blast res:"..tostring(br))
	 print("    Radius:"..tostring(r))
	 print("      rstr:"..tostring(rstr))
	 print("should blow? ".. tostring(rstr >= res))
      end
      -- If blast strength is more than resistance...
      if rstr >= res * rnd[idx] then
	local params = callbacks[hash]
        if not params or rstr > params.rstr then
        --if not params then
	   -- If no callback has been created for this node
          callbacks[hash] = {
            callback = def and def.on_blast_break or 1,
            npos_x = npos_x,
            npos_y = npos_y,
            npos_z = npos_z,
            rstr = rstr / (r * r),
            idx = idx,
          }
	  -- If the ray destroys a block, it has to "spend" its blast strength on doing that
	  -- Why doesn't it have to "spend" blast strength when it doesn't destroy a block?
	  rstr = math.max(rstr - res, 0)
        elseif rstr > params.rstr then
          params.callback = def and def.on_blast_shock or 1
          params.npos_x = npos_x
          params.npos_y = npos_y
          params.npos_z = npos_z
          params.rstr = rstr / (r * r)
        end
      else
	-- This ray is not strong enough to destroy this node
        local params = callbacks[hash]
        if not callbacks[hash] then
          callbacks[hash] = {
            callback = def and def.on_blast_shock or 2,
            npos_x = npos_x,
            npos_y = npos_y,
            npos_z = npos_z,
            rstr = rstr / (r * r),
            idx = idx
          }
        elseif rstr > params.rstr then
          params.npos_x = npos_x
          params.npos_y = npos_y
          params.npos_z = npos_z
          params.rstr = rstr / (r * r)
        end

        break
      end
      rpos_x = rpos_x + rdir_x
      rpos_y = rpos_y + rdir_y
      rpos_z = rpos_z + rdir_z
    end
  end

  -- Update entities
  local objs = minetest.get_objects_inside_radius(pos, radius)
  for _, obj in pairs(objs) do
    local opos = obj:get_pos()
    local npos_x = math.floor(opos.x + 0.5)
    local npos_y = math.floor(opos.y + 1.0)
    local npos_z = math.floor(opos.z + 0.5)
    local hash = (npos_z + 32768) * 65536 * 65536 +
        (npos_y + 32768) * 65536 +
        npos_x + 32768
    local params = callbacks[hash]

    if not params then
      break
    end

    local def = minetest.registered_entities[obj.name]
    local callback = def and def.on_blast_hit
    local rstr = params.rstr

    local odir_x = opos.x - pos.x
    local odir_y = opos.y - pos.y
    if odir_y == 0 then
      odir_y = 0.0000001 -- Avoiding odir_len becoming exactly zero
    end
    local odir_z = opos.z - pos.z

    local odir_len = math.hypot(odir_x, math.hypot(odir_y, odir_z))

    odir_x = odir_x / odir_len
    odir_y = odir_y / odir_len
    odir_z = odir_z / odir_len

    local dmg = rstr * 0.2

    if not callback or
        callback(obj, rstr, { x = odir_x, y = odir_y, z = odir_z }) then
      if not obj:get_armor_groups().immortal then
        obj:punch(obj, 1.0, {
          full_punch_interval = 1.0,
          damage_groups = { fleshy = dmg }
        })
      end
    end
    if not callback and not obj:is_player() then
       local vel = obj:get_velocity()
       if vel ~= nil then
	  local push = rstr * 0.05
	  
	  vel.x = vel.x + odir_x * push
	  vel.y = vel.y + odir_y * push
	  vel.z = vel.z + odir_z * push

	  obj:set_velocity(vel)
       end
    end
    if not callback and obj:is_player() then
      local push = rstr * 0.05
      local vel = {}
      vel.x = odir_x * push
      vel.y = odir_y * push
      vel.z = odir_z * push
      obj:add_velocity(vel)
    end
  end

  -- How many nodes get destroyed by explosion (for logging)
  local n_break = 0

  -- Handle callbacks
  for _, params in pairs(callbacks) do
    local idx = params.idx



    
    if data[idx] ~= AIR_CID
    and not minetest.is_protected(vector.new(params.npos_x, params.npos_y, params.npos_z), "") then
      local callback = params.callback
      local npos_x = params.npos_x
      local npos_y = params.npos_y
      local npos_z = params.npos_z
      local rstr = params.rstr

      if callback == 1 then
        n_break = n_break + 1
        data[idx] = AIR_CID
      else
        local ndir_x = npos_x - pos.x
        local ndir_y = npos_y - pos.y
        local ndir_z = npos_z - pos.z
        local ndir_len = math.hypot(ndir_x, math.hypot(ndir_y, ndir_z))
        ndir_x = ndir_x / ndir_len
        ndir_y = ndir_y / ndir_len
        ndir_z = ndir_z / ndir_len

        if callback == 2 then
          if rstr > 50 * rnd[idx] then
            local push = rstr * 0.05

            local npos2_x = math.floor(npos_x + ndir_x + 0.5)
            local npos2_y = math.floor(npos_y + ndir_y + 0.5)
            local npos2_z = math.floor(npos_z + ndir_z + 0.5)

            local idx2 = (npos2_z - emin_z) * zstride + (npos2_y - emin_y) *
            ystride + npos2_x - emin_x + 1

            local def2 = node_defs[data[idx2]]

            -- Check if the node can actually fly
            if flying_nodes and def2 and (def2.liquidtype or 'none') == 'none' and
              def2.buildable_to then
              local npos = { x = npos_x, y = npos_y, z = npos_z }
              local meta = minetest.get_meta(npos)
              local node = minetest.get_node(npos)
              node.level = minetest.get_node_level(npos)
              local ent = minetest.add_entity(npos, '__builtin:falling_node')
              ent:get_luaentity():set_node(node, meta and meta:to_table() or {})

              ent:set_velocity({
                x = ndir_x * push,
                y = ndir_y * push,
                z = ndir_z * push
              })

              data[idx] = AIR_CID
            end
          end
        else
          local npos = { x = npos_x, y = npos_y, z = npos_z }
          local ndir = { x = ndir_x, y = ndir_y, z = ndir_z }

          if callback(npos, rstr, ndir) then
            data[idx] = AIR_CID
          end
        end
      end
    end
  end

  -- Log explosion
  minetest.log('action', 'Explosion at ' .. minetest.pos_to_string(pos) ..
    ' with strength ' .. strength .. ' and radius ' .. radius ..
    ' destroys ' .. n_break .. ' nodes')

  -- Update environment
  vm:set_data(data)
  vm:write_to_map(data)
  vm:update_liquids()
end

-- Create an undirected explosion with strength at pos.
--
-- Parameters:
--   pos - The position where the explosion originates from
--   explosion_def - Table with properties that define the explosion
--
-- Explosion definition properties:
--   strength - The blast strength of the explosion
--   shape - The shape of the explosion.  It is an array of normalized vectors
--           which determine the direction of each ray in the explosion.  When
--           omitted the shape becomes a sphere with appropriate number of
--           rays.
--   radius - The maximum distance each ray will go.  Entities or nodes past
--            this radius will not be affected by the explosion.  If omitted,
--            it is the cube root of the strength value.
function explosions.explode(pos, explosion_def)
  assert(explosion_def)
  local strength = explosion_def.strength
  assert(strength)
  local radius = explosion_def.radius or math.ceil(strength ^ (1 / 3))

  local shape = explosion_def.shape

  if not shape then
    if not sphere_shapes[radius] then
      sphere_shapes[radius] = compute_sphere_rays(radius)
    end
    shape = sphere_shapes[radius]
  end

  trace_explode(pos, strength, shape, radius)
end
