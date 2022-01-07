-- trm_custom/init.lua

--[[
   treasurer.register_treasure - registers a new treasure
   (this means the treasure will be ready to be spawned by treasure spawning mods.
   name: name of resulting ItemStack, e.g. “mymod:item”
   rarity: rarity of treasure on a scale from 0 to 1 (inclusive). lower = rarer
   preciousness: preciousness of treasure on a scale from 0 (“scorched stuff”) to 10 (“diamond block”).
   count: optional value which specifies the multiplicity of the item. Default is 1. See count syntax help in this file.
   wear: optional value which specifies the wear of the item. Default is 0, which disables the wear. See wear syntax help in this file.
   treasurer_groups: (optional) a table of group names to assign this treasure to. If omitted, the treasure is added to the default group.
   This function does some basic parameter checking to catch the most obvious mistakes. If invalid parameters have been passed, the input is rejected and the function returns false. However, it does not cover every possible mistake, so some invalid treasures may slip through.

   returns: true on success, false on failure
]]
treasurer.register_treasure("covid19:vaccine_jj", 0.25, 0, 1,nil,"default_dungeon_loot")
treasurer.register_treasure("covid19:mask", 0.25, 0, 1,nil,"default_dungeon_loot")
treasurer.register_treasure("default:gold_ingot",0.5,0, {1,10},nil,"default_dungeon_loot")
treasurer.register_treasure("default:wood",0.5, 0, {1,20},nil,"default_dungeon_loot")
