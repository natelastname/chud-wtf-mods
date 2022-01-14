periodic_msgs = {}
periodic_msgs.interval_secs = 240
periodic_msgs.msgs = {
   "You can raid other faction's bases using tools from the covid19 mod.",
   "Johnson and Johnson vaccines are throwable bombs found in dungeon chests.",
   "The decontaminator is a suicide bomb with a 1:5 chance of exploding when used.",
   "Type /help f to view a list of faction related commands.",
   "Factions cannot claim land below y=-200.",
   "Be very careful who you trust with your faction's password.",
   "If you forget your faction's password, the faction owner can retrieve it using /f info",
   "All doors placed in faction claimed territory are automatically protected.",
   "All forms of chest protection have been disabled.",
   "There is a 50% chance a random item modifier will be applied to any crafted tools."
}
periodic_msgs.counter = 0
periodic_msgs.color = "#ff9999"
periodic_msgs.label = "<http://chud.wtf> "

function print_message()
   periodic_msgs.counter = periodic_msgs.counter + 1
   if periodic_msgs.counter > #periodic_msgs.msgs then
      periodic_msgs.counter = 1
   end
   local msg = periodic_msgs.msgs[periodic_msgs.counter]
   msg = periodic_msgs.label .. msg
   msg = minetest.colorize(periodic_msgs.color, msg)
   minetest.chat_send_all(msg)
   minetest.after(periodic_msgs.interval_secs, print_message)
end

minetest.after(periodic_msgs.interval_secs, print_message)
