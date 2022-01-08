local S = minetest.get_translator("currency")

currency.shop = {}
if minetest.global_exists("default") then
	default.shop = currency.shop
end

currency.shop.current_shop = {}
currency.shop.formspec = {
	customer = function(pos)
		local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z
		local formspec = "size[8,9.5]"..
		"label[0,0;" .. S("Customer gives (pay here!)") .. "]"..
		"list[current_player;customer_gives;0,0.5;3,2;]"..
		"label[0,2.5;" .. S("Customer gets:") .. "]"..
		"list[current_player;customer_gets;0,3;3,2;]"..
		"label[5,0;" .. S("Owner wants:") .. "]"..
		"list["..list_name..";owner_wants;5,0.5;3,2;]"..
		"label[5,2.5;" .. S("Owner gives:") .. "]"..
		"list["..list_name..";owner_gives;5,3;3,2;]"..
		"list[current_player;main;0,5.5;8,4;]"..
		"button[3,2;2,1;exchange;" .. S("Exchange") .. "]"
		return formspec
	end,
	owner = function(pos)
		local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z
		local formspec = "size[8,9.5]"..
		"label[0,0;" .. S("Customers gave:") .. "]"..
		"list["..list_name..";customers_gave;0,0.5;3,2;]"..
		"label[0,2.5;" .. S("Your stock:") .. "]"..
		"list["..list_name..";stock;0,3;3,2;]"..
		"label[4,0;" .. S("You want:") .. "]"..
		"list["..list_name..";owner_wants;4,0.5;3,2;]"..
		"label[4,2.5;" .. S("In exchange, you give:") .. "]"..
		"list["..list_name..";owner_gives;4,3;3,2;]"..
		"label[0,5;" .. S("Owner, Use (E)+Place (right mouse button) for customer interface") .. "]"..
		"list[current_player;main;0,5.5;8,4;]"
		return formspec
	end,
}

local have_pipeworks = minetest.global_exists("pipeworks")

currency.shop.check_privilege = function(listname,playername,meta)
	--[[if listname == "pl1" then
		if playername ~= meta:get_string("pl1") then
			return false
		elseif meta:get_int("pl1step") ~= 1 then
			return false
		end
	end
	if listname == "pl2" then
		if playername ~= meta:get_string("pl2") then
			return false
		elseif meta:get_int("pl2step") ~= 1 then
			return false
		end
	end]]
	return true
end


currency.shop.give_inventory = function(inv,list,playername)
	player = minetest.get_player_by_name(playername)
	if player then
		for k,v in ipairs(inv:get_list(list)) do
			player:get_inventory():add_item("main",v)
			inv:remove_item(list,v)
		end
	end
end

currency.shop.cancel = function(meta)
	--[[currency.shop.give_inventory(meta:get_inventory(),"pl1",meta:get_string("pl1"))
	currency.shop.give_inventory(meta:get_inventory(),"pl2",meta:get_string("pl2"))
	meta:set_string("pl1","")
	meta:set_string("pl2","")
	meta:set_int("pl1step",0)
	meta:set_int("pl2step",0)]]
end

currency.shop.exchange = function(meta)
	--[[currency.shop.give_inventory(meta:get_inventory(),"pl1",meta:get_string("pl2"))
	currency.shop.give_inventory(meta:get_inventory(),"pl2",meta:get_string("pl1"))
	meta:set_string("pl1","")
	meta:set_string("pl2","")
	meta:set_int("pl1step",0)
	meta:set_int("pl2step",0)]]
end

local check_stock = function(
	pos
)
	local meta = minetest.get_meta(
		pos
	)
	local minv = meta:get_inventory(
	)
	local gives = minv:get_list(
		"owner_gives"
	)
	local can_exchange = true
	for i, item in pairs(
		gives
	) do
		if not minv:contains_item(
			"stock",
			item
		) then
			can_exchange = false
		end
	end
	local owner = meta:get_string(
		"owner"
	)
	if can_exchange then
		meta:set_string(
			"infotext",
			S(
				"Exchange shop (owned by @1)",
				owner
			)
		)
		local applicable = "currency:shop"
		local node = minetest.get_node(
			pos
		)
		if node.name == applicable then
			return
		end
		node.name = applicable
		minetest.swap_node(
			pos,
			node
		)
	else
		meta:set_string(
			"infotext",
			S(
				"Exchange shop (owned by @1)",
				owner
			) .. ", " .. S(
				"out of stock"
			)
		)
		local applicable = "currency:shop_empty"
		local node = minetest.get_node(
			pos
		)
		if node.name == applicable then
			return
		end
		node.name = applicable
		minetest.swap_node(
			pos,
			node
		)
	end
end

minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname == "currency:shop_formspec" and fields.exchange ~= nil and fields.exchange ~= "" then
		local name = sender:get_player_name()
		local pos = currency.shop.current_shop[name]
		local meta = minetest.get_meta(pos)
		if meta:get_string("owner") == name then
			minetest.chat_send_player(name, S("This is your own shop, you can't exchange to yourself!"))
		else
			local minv = meta:get_inventory()
			local pinv = sender:get_inventory()
			local invlist_tostring = function(invlist)
				local out = {}
				for i, item in pairs(invlist) do
					out[i] = item:to_string()
				end
				return out
			end
			local wants = minv:get_list("owner_wants")
			local gives = minv:get_list("owner_gives")
			if wants == nil or gives == nil then return end -- do not crash the server
			-- Check if we can exchange
			local can_exchange = true
			local owners_fault = false
			for i, item in pairs(wants) do
				if not pinv:contains_item("customer_gives",item) then
					can_exchange = false
				end
			end
			for i, item in pairs(gives) do
				if not minv:contains_item("stock",item) then
					can_exchange = false
					owners_fault = true
				end
			end
			if can_exchange then
				for i, item in pairs(wants) do
					pinv:remove_item("customer_gives",item)
					minv:add_item("customers_gave",item)
				end
				for i, item in pairs(gives) do
					minv:remove_item("stock",item)
					pinv:add_item("customer_gets",item)
				end
				minetest.chat_send_player(name, S("Exchanged!"))
				check_stock(
					pos
				)
			else
				if owners_fault then
					minetest.chat_send_player(name, S("Exchange can not be done, contact the shop owner."))
				else
					minetest.chat_send_player(name, S("Exchange can not be done, check if you put all items!"))
				end
			end
		end
	end
end)
