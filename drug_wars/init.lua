-- MOD STRUCT INITIALIZATION

drug_wars = {}
drug_wars.path = minetest.get_modpath("drug_wars")
drug_wars.aftereffects = {}
drug_wars.addictions = {}


local illegal_items = {
   "drug_wars:crack",
   "drug_wars:hashish",
   "drug_wars:opium_ball",
   "drug_wars:weed",
   "drug_wars:cocaine",
   "drug_wars:cannabis_inflorescence",
   "drug_wars:cannabis_resin",
   "drug_wars:coca_leaf",
   "drug_wars:raw_opium",
   "drug_wars:seed_cannabis",
   "drug_wars:seed_coca",
   "drug_wars:seed_opiumpoppy"
}

-- Custom stuff
function drug_wars.player_has_drugs(name)
   print("Checking for drugs")
   local player = minetest.get_player_by_name(name)
   local inv = player:get_inventory()
   local slots = inv:get_lists()
   for slot in pairs(slots) do
      for i, item in ipairs(illegal_items) do
	 if inv:contains_item(slot, item) then
	    return true, item
	 end
      end
   end
   
   return false, nil
end




-- IMPORTS

dofile(drug_wars.path.."/config.lua")
dofile(drug_wars.path.."/helpers.lua")
dofile(drug_wars.path.."/globalupdates.lua")
dofile(drug_wars.path.."/hpeffects.lua")

if drug_wars.ENABLE_INVSEARCH then
    dofile(drug_wars.path.."/invsearch.lua")
end

if drug_wars.ENABLE_MACHETES then
    dofile(drug_wars.path.."/machetes.lua")
end

if drug_wars.ENABLE_PIPES then
    dofile(drug_wars.path.."/pipes.lua")
end

if drug_wars.ENABLE_CANNABIS then
    dofile(drug_wars.path.."/cannabis.lua")
end

if drug_wars.ENABLE_COCA then
    dofile(drug_wars.path.."/coca.lua")
end

if drug_wars.ENABLE_OPIUMPOPPY then
    dofile(drug_wars.path.."/opiumpoppy.lua")
end
