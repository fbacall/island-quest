door = get_entity('hut_door')
gob = get_entity('gob')
stop(player)
move(player, door.x, door.y - 32)
move(player, door.x, door.y - 28)
play_sound('open')
door.tile_id += 1
gob.visible = true
move(gob, door.x, door.y - 8)

if has_item?('nails')
  dialogue(:top, "Go away.", gob)
else
  dialogue(:bottom, "Hello.", player)
  dialogue(:top, "What do you want?", gob)
  dialogue(:bottom, "I seem to be stranded here. Do you know a way off this island?", player)
  dialogue(:top, "This is paradise. Why would you want to leave?", gob)
  dialogue(:bottom, "I need to feed my cat.", player)
  dialogue(:top, "Hmm. Maybe you can do something for me first.", gob)
  dialogue(:top, "I recently destroyed the southern bridge in a fit of rage.", gob)
  dialogue(:bottom, "Oh dear.", player)
  dialogue(:top, "You look handy, maybe you could fix it for me?", gob)
  dialogue(:top, "Take these nails. I think I left a hammer around here somewhere.", gob)
  dialogue(:bottom, "Got it.", player)

  ItemEntity.new('nails', tile_id: 198).interact
end

move(gob, door.x, door.y)
gob.visible = false
play_sound('open')
door.tile_id -= 1
