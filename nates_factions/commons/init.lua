minetest.register_abm({
  nodenames = {"default:chest_locked"},
  interval = 4,
  chance = 1,
  action = function(pos, node)
    node.name = "default:chest"
    minetest.swap_node(pos, node)
  	local meta = minetest.get_meta(pos)
  	meta:set_string("owner", "")
  	meta:set_string("infotext", "")
  	minetest.add_particlespawner({
  		amount = 1,
  		time = 0.25,
  		minpos = {x=pos.x, y=pos.y+0.3, z=pos.z},
  		maxpos = {x=pos.x, y=pos.y+2, z=pos.z},
  		minvel = {x = -1, y = 1, z = -1},
  		maxvel = {x = 1,  y = 6,  z = 1},
  		minacc = {x = 0, y = -6, z = 0},
  		maxacc = {x = 0, y = -6, z = 0},
  		minexptime = 0.5,
  		maxexptime = 1,
  		minsize = 2,
  		maxsize = 2,
  		texture = "commons_particle.png",
  		glow = 5,
    })
  end
})