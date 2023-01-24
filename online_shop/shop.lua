
local contexts = {}

local function get_context(name)
   local context = contexts[name] or {}
   contexts[name] = context
   return context
end

function online_shop.shop_server(pos)
   local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z
   local meta = minetest.get_meta(pos)
   local meta_table = meta:to_table()
   local store_name_t = meta:get_string("store_name")
   local item_label_t = meta:get_string("item_label")
   if store_name_t == nil or store_name_t == "" then store_name_t = "" end
   if item_label_t == nil or item_label_t == "" then item_label_t = "" end
   local formspec = "size[8.5,11.5]"..
      "label[0,0;" .. "Customers gave:" .. "]"..
      "list["..list_name..";customers_gave;0,0.5;4,2;]"..
      "label[0,2.5;" .. "Your stock:" .. "]"..
      "list["..list_name..";stock;0,3;4,2;]"..
      "label[4.5,0;" .. "You want:" .. "]"..
      "list["..list_name..";owner_wants;4.5,0.5;4,2;]"..
      "label[4.5,2.5;" .. "In exchange, you give:" .. "]"..
      "list["..list_name..";owner_gives;4.5,3;4,2;]"..
      "field[0.3,5.548;4,1;store_name;Store Name:;"..store_name_t.."]"..
      "button_exit[5,5.2;3,1;finish;Finish]"..
      "field[0.3,6.7;4,1;item_label;Item Label (i.e. 99 Clay Blocks for 10mg):;"..item_label_t.."]"..
      "list[current_player;main;0.25,7.5;8,4;]"
   return formspec
end




minetest.register_node("online_shop:shop_server", {
                          description = "Shop Server",
                          tiles = {
                             "shop_shop_server_top.png",
                             "shop_shop_server_top.png",
                             "shop_shop_server_side.png",
                             "shop_shop_server_side.png",
                             "shop_shop_server_side.png",
                             "shop_shop_server_front.png"
                          },
                          paramtype = "light",
                          paramtype2 = "facedir",
                          sunlight_propagates = false,
                          is_ground_content = false,
                          groups = {choppy = 3, oddly_breakable_by_hand = 2, wood = 1},
                          sounds = default.node_sound_wood_defaults(),
                          
                          after_place_node = function(pos, placer, itemstack)
                             local player_meta = placer:get_meta()
                             if player_meta:get_string("online_shop_banstate") ~= "banned" then
                                local owner = placer:get_player_name()
                                local meta = minetest.get_meta(pos)
                                meta:set_string("infotext", "Shopping Server (owned by "..owner..")")
                                meta:set_string("owner", owner)
                                meta:set_string("store_name", "")
                                meta:set_string("item_label", "")
                                local inv = meta:get_inventory()
                                inv:set_size("customers_gave", 4*2)
                                inv:set_size("stock", 4*2)
                                inv:set_size("owner_wants", 4*2)
                                inv:set_size("owner_gives", 4*2)
                             else
                                minetest.remove_node(pos)
                                minetest.chat_send_player(placer:get_player_name(), "You have been banned from creating Shop Servers")
                             end
                          end,

                          on_destruct = function(pos)
                             local meta = minetest.get_meta(pos)
                             online_shop.unregister_shop({
                                   store_name = meta:get_string("store_name"),
                                   item_label = meta:get_string("item_label"),
                                   owner = meta:get_string("owner"),
                                   pos = pos
                             })
                          end,
                          
                          on_rightclick = function(pos, node, clicker, itemstack)
                             -- Always open the admin interface when a shop server is opened by right clicking
                             -- This prevents the shop server from being used to hide items.
                             local context = get_context(clicker:get_player_name())
                             context.pos = pos
                             minetest.show_formspec(clicker:get_player_name(), "online_shop:shop_server_formspec", online_shop.shop_server(pos))
                          end
})

minetest.register_craft({
      type = "shapeless",
      output = "online_shop:shop_server",
      recipe = {"default:chest_locked", "online_shop:shop_server_motherboard"}
})



local function set_val(key, tbl)
   storage:set_string(key, minetest.serialize(tbl))
end
local function get_val(key)
   return minetest.deserialize(storage:get_string(key))
end

-- Return a list of all stores (groups)
-- Currently, the order of the list is undefined
function online_shop.list_stores()
   local groups = {}
   local groups_dict = get_val("groups_dict")
   for k in pairs(groups_dict) do
      table.insert(groups, k) 
   end
   return groups
end


-- The owner of a shop isn't that important in this fork.
-- We could return garbage and it would be fine.
function online_shop.get_shop_owner(storename)   
   local groups_dict = get_val("groups_dict")
   if groups_dict[storename] == nil then
      return nil
   end
   local stores_dict = get_val("stores_dict")
   for k in pairs(groups_dict[storename]) do
      return stores_dict[groups_dict[storename][k]].owner
   end
   return nil
end

function online_shop.get_item_labels(store_name)
   local groups_dict = get_val("groups_dict")
   return groups_dict[store_name]
end

function online_shop.store_exists(store_name)
   local groups_dict = get_val("groups_dict")
   if next(groups_dict[store_name]) then
      return true
   end
   return false
end



function online_shop.pos_list_as_table(store_name)
   local groups_dict = get_val("groups_dict")
   if groups_dict[store_name] == nil then
      return {}
   end

   local res = {}
   for k in pairs(groups_dict[store_name]) do
      table.insert(res, groups_dict[store_name][k])
   end
   return res
end


--[[
   Shop def example:
   online_shop.register_shop({
   store_name = "Store name",
   item_label = "Item label",
   owner = "owner name",
   pos = position vector
   })
   
   An online shop is valid if pos is the position of an online shop node
   whose metadata has a store_name that agrees with the argument store_name. 
   If the metadata of the block at pos does not agree with store_name or isn't
   an online_shop, the shop is invalid and will be discarded from the mod storage.

]]--
function online_shop.register_shop(shop_def)
   --print("------------ Registering shop:")
   --print(dump(shop_def))
   
   if storage:get_string("stores_dict") == "" then
      set_val("stores_dict", {})
   end
   
   if storage:get_string("groups_dict") == "" then
      set_val("groups_dict", {})
   end

   
   local stores_dict = get_val("stores_dict")
   local pos_hash = minetest.pos_to_string(shop_def.pos)
   stores_dict[pos_hash] = shop_def   
   set_val("stores_dict", stores_dict)
   

   local groups_dict = get_val("groups_dict")
   if groups_dict[shop_def.store_name] == nil then
      groups_dict[shop_def.store_name] = {}
   end

   groups_dict[shop_def.store_name][shop_def.item_label] = pos_hash

   set_val("groups_dict", groups_dict)
   
   local meta = minetest.get_meta(shop_def.pos)
   meta:set_string("store_name", shop_def.store_name)
   meta:set_string("item_label", shop_def.item_label)
   meta:set_string("owner", shop_def.owner)

   --print("------------- Stores Dict: -----------")
   --print(dump(get_val("stores_dict")))
   --print("------------- Groups Dict: -----------")
   --print(dump(get_val("groups_dict")))
   
   return true, "Shop " .. shop_def.store_name .. " successfully registered."
end

--[[
   Try to forget the online_shop determined by shop_def.
]]--
function online_shop.unregister_shop(shop_def)
   if storage:get_string("stores_dict") == "" then
      set_val("stores_dict", {})
   end
   
   if storage:get_string("groups_dict") == "" then
      set_val("groups_dict", {})
   end
   if shop_def.store_name == nil or shop_def.item_label == nil then
      -- Not enough information
      return
   end

   local stores_dict = get_val("stores_dict")
   local pos_hash = minetest.pos_to_string(shop_def.pos)
   stores_dict[pos_hash] = nil
   set_val("stores_dict", stores_dict)   

   --print("------------ Unregistering ".. shop_def.store_name)
   local groups_dict = get_val("groups_dict")
   --print("Old groups dict:")
   --print(dump(groups_dict))

   if groups_dict[shop_def.store_name] == nil then
      -- This shop was never registered, therefore we have nothing
      -- to unregister
      --print("Shop was never registered.")
      return
   end
   groups_dict[shop_def.store_name][shop_def.item_label] = nil
   if not next(groups_dict[shop_def.store_name]) then
      -- The group is empty, delete it
      --print("Group is now empty.")
      groups_dict[shop_def.store_name] = nil
   end
   --print("New groups dict:")
   --print(dump(groups_dict))
   set_val("groups_dict", groups_dict)

end

-- This handles the case where a player hits "finish" in the shop manage menu.
minetest.register_on_player_receive_fields(function(sender, formname, fields)
      -- Sender: player object of user submitting the formspec
      if formname ~= "online_shop:shop_server_formspec" then
         return
      end
      if fields.finish == nil then
         return
      end
      if fields.finish == "" then
         return
      end
      local sender_name = sender:get_player_name()
      local context = get_context(sender:get_player_name())
      local pos = context.pos
      local meta = minetest.get_meta(pos)


      local orig_store_name = meta:get_string("store_name")
      local orig_item_label = meta:get_string("item_label")
      local new_item_label = fields.item_label
      local new_store_name = fields.store_name
      
      if minetest.get_node(pos).name ~= "online_shop:shop_server" then
         -- This (probably) indicates that the shop got destroyed while in use.
         minetest.chat_send_player(sender_name, "Operation failed, shop server no longer exists.")
         return
      end
      
      
      if new_store_name == nil or new_store_name == ""
         or new_item_label == nil or new_item_label == "" then
         -- This indicates that the fields were not valid.
         minetest.chat_send_player(sender_name, "Operation failed. Enter a valid 'Store Name' and 'Item Label'.")
         return
      end
      
      online_shop.unregister_shop({
            store_name = orig_store_name,
            item_label = orig_item_label,
            owner = meta:get_string("owner"),
            pos = pos
      })
      
      local result, msg = online_shop.register_shop({
            store_name = fields.store_name,
            item_label = fields.item_label,
            owner = meta:get_string("owner"),
            pos = pos
      })
      
      minetest.chat_send_player(sender_name, msg)
      
end)

