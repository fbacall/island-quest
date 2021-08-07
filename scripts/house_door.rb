door = get_entity('house_door')
witch = get_entity('witch')
stop(player)
move(player, door.x, door.y - 32)
move(player, door.x, door.y - 28)
play_sound('open')
door.tile_id += 1
witch.visible = true
move(witch, door.x, door.y - 8)

if has_item?('pickaxe')
  dialogue(:top, "Hello, young man!", witch)
elsif has_item?('ring')
  dialogue(:bottom, "I found this ring...", player)
  dialogue(:top, "Gee whiz! Thanks!", witch)
  remove_item('ring')
  dialogue(:top, "As a token of my gratitude, please have this snorkel.", witch)
  ItemEntity.new('snorkel', 197).interact
elsif has_item?('snorkel')
  dialogue(:top, "Hello, young man! Be sure to explore the island to the north east!", witch)
else
  dialogue(:top, "Here, take this, a frail old witch has no use for such a thing.", witch)
  ItemEntity.new('pickaxe', 182).interact
end

move(witch, door.x, door.y)
witch.visible = false
play_sound('open')
door.tile_id -= 1
