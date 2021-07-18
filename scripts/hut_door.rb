if has_item?('nails')
  dialogue(:top, "Go away.")
else
  dialogue(:bottom, "Hello? Anyone home?", player)
  dialogue(:top, "What do you want?")
  dialogue(:bottom, "I'm talking to myself now.", player)
  dialogue(:top, "The bridge is broken... Take these nails. Maybe you can find a hammer around here somehere?")

  ItemEntity.new('nails', 198).interact
end
