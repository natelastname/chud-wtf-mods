-- /area radar
local sp = simple_protection
local S = sp.translator
local data_cache

local function colorize_area(name, force)
   if force == "unclaimed" or not force and not data_cache then
      -- Area not claimed
      return "[colorize:#FFF:50"
   end
   if force == "owner" or not force and data_cache.owner == name then
      return "[colorize:#0F0:180"
   end
   -- Claimed but not shared
   return "[colorize:#000:180"
end

local function combine_escape(str)
	return str:gsub("%^%[", "\\%^\\%["):gsub(":", "\\:")
end

function sp.radar(name)
   local player = minetest.get_player_by_name(name)

   -- It's OK if fact_name is nil (meaning, the player is not in a faction.)
   local fact_name = factions.get_player_faction(name)
   
   local player_pos = player:get_pos()
   local pos = sp.get_location(player_pos)
   local map_w = 15 - 1
   local map_wh = map_w / 2
   local img_w = 20

   local get_single = sp.get_claim
   local function getter(x, ymod, z)
      data_cache = get_single(x .."," .. (pos.y + ymod) .. "," .. z, true)
      return data_cache
   end

   local parts = ""
   for z = 0, map_w do
      for x = 0, map_w do
	 local ax = pos.x + x - map_wh
	 local az = pos.z + z - map_wh
	 local img = "simple_protection_radar.png"

	 if     getter(ax,  0, az) then
	    -- Using default "img" value
	 elseif getter(ax, -1, az) then
	    -- Check for claim below first
	    img = "simple_protection_radar_down.png"
	 elseif getter(ax,  1, az) then
	    -- Last, check upper area
	    img = "simple_protection_radar_up.png"
	 end
	 parts = parts .. string.format(":%i,%i=%s",
					x * img_w, (map_w - z) * img_w,
					combine_escape(img .. "^" .. colorize_area(fact_name)))
	 -- Somewhat dirty hack for [combine. Escape everything
	 -- to get the whole text passed into TextureSource::generateImage()
      end
   end

   -- Player's position marker (8x8 px)
   local pp_x = player_pos.x / sp.claim_size
   local pp_z = player_pos.z / sp.claim_size
   -- Get relative position to the map, add map center offset, center image
   pp_x = math.floor((pp_x - pos.x + map_wh) * img_w + 0.5) - 4
   pp_z = math.floor((pos.z - pp_z + map_wh + 1) * img_w + 0.5) - 4
   local marker_str = string.format(":%i,%i=%s", pp_x, pp_z,
				    combine_escape("object_marker_red.png^[resize:8x8"))

   -- Rotation calculation
   local dir_label = S("North @1", "(Z+)")
   local dir_mod = ""
   local look_angle = player.get_look_horizontal and player:get_look_horizontal()
   if not look_angle then
      look_angle = player:get_look_yaw() - math.pi / 2
   end
   look_angle = look_angle * 180 / math.pi

   if     look_angle >=  45 and look_angle < 135 then
      dir_label = S("West @1", "(X-)")
      dir_mod = "^[transformR270"
   elseif look_angle >= 135 and look_angle < 225 then
      dir_label = S("South @1", "(Z-)")
      dir_mod = "^[transformR180"
   elseif look_angle >= 225 and look_angle < 315 then
      dir_label = S("East @1", "(X+)")
      dir_mod = "^[transformR90"
   end
   minetest.show_formspec(name, "covfefe",
			  "size[10.5,7]" ..
			     "button_exit[9.5,0;1,1;exit;X]" ..
			     "label[2,0;"..dir_label.."]" ..
			     "image[0,0.5;7,7;" ..
			     minetest.formspec_escape("[combine:300x300"
							 .. parts .. marker_str)
			     .. dir_mod .. "]" ..
			     "label[0,6.8;1 " .. S("square = 1 area = @1x@2x@3 nodes (X,Y,Z)",
						   sp.claim_size,
						   sp.claim_height,
						   sp.claim_size) .. "]" ..
			     "image[6.25,1.25;0.5,0.5;object_marker_red.png]" ..
			     "label[7,1.25;" .. S("Your position") .. "]" ..
			     "image[6,2;1,1;simple_protection_radar.png^"
			     .. colorize_area(nil, "owner") .. "]" ..
			     "label[7,2.25;" .. S("Your area") .. "]" ..
			     "image[6,3;1,1;simple_protection_radar.png^"
			     .. colorize_area(nil, "other") .. "]" ..
			  "label[7,3;" .. S("Area claimed\nNo access for you") .. "]" ..
			     "image[6,4;1,1;simple_protection_radar.png^"
			     .. colorize_area(nil, "*all") .. "]" ..
			  "label[7,4.25;" .. S("Access for everybody") .. "]" ..
			     "image[6,5;1,1;simple_protection_radar_down.png]" ..
			     "image[7,5;1,1;simple_protection_radar_up.png]" ..
			     "label[6,6;" .. S("One area unit (@1m) up/down\n-> no claims on this Y level",
					       sp.claim_height) .. "]"
   )
end
