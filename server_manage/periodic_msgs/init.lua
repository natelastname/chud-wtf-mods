periodic_msgs = {}
periodic_msgs.interval_secs = 300
periodic_msgs.msgs = {
   "You can raid other faction's bases using tools from the covid19 mod.",
   "Johnson and Johnson vaccines are throwable bombs found in dungeon chests.",
   "Most metal blocks can only be destroyed using Pfizer vaccines.",
   "Type /help f to view a list of faction related commands.",
   "Factions cannot claim land below y=-200.",
   "Be very careful who you trust with your faction's password.",
   "If you forget your faction's password, the faction owner can retrieve it using /f info",
   "All doors placed in faction claimed territory are automatically protected.",
   "All forms of chest protection have been disabled.",
   "This server has anticheat",
   "There is a 50% chance a random item modifier will be applied to any crafted tools.",
   "Send emails to offline players using the command '/mail <playername> <message>'",
   "Visit http://chud.wtf for a link to the Discord"
}
periodic_msgs.counter = 0
periodic_msgs.color = "#ff9999"
periodic_msgs.label = "<http://chud.wtf> "


local discordmt_enabled = minetest.get_modpath("discordmt")


function print_message()
   periodic_msgs.counter = periodic_msgs.counter + 1
   if periodic_msgs.counter > #periodic_msgs.msgs then
      periodic_msgs.counter = 1
   end
   local msg = periodic_msgs.msgs[periodic_msgs.counter]
   msg = periodic_msgs.label .. msg
   msg = minetest.colorize(periodic_msgs.color, msg)
   if discordmt_enabled then
      minetest.log("action", "DISCORDMT ENABLED")
      discord.chat_send_all(msg)
   else
      minetest.log("action", "DISCORDMT not enabled")
      minetest.chat_send_all(msg)
   end
   minetest.after(periodic_msgs.interval_secs, print_message)
end

minetest.after(periodic_msgs.interval_secs, print_message)
