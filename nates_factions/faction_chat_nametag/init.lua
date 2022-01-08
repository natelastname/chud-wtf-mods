


minetest.register_on_chat_message(function(name, message)
      local tag = "[test]"
      minetest.chat_send_all(tag .. name .. ":" .. message)
      return true
end)
