-- online_shop/cull_dead_shops.lua


-- Go through the list of shops once on startup. Remove any invalid shops.
--[[
do
   local stores = online_shop.list_stores()
   for i, storename in ipairs(stores) do
      print("Store :".. storename)


      
      -- Here, we could possibly check if the owner was banned 
      online_shop.get_shop_owner(storename)

      

      
   end

   
end
]]--
