door = get_entity('house_door')
witch = get_entity('witch')
stop(player)
move(player, door.x, door.y - 32)
move(player, door.x, door.y - 28)
play_sound('open')
door.tile_id += 1
witch.visible = true
move(witch, door.x, door.y - 8)

dialogue(:top, "Go away. I am not implemented yet.", witch)

move(witch, door.x, door.y)
witch.visible = false
play_sound('open')
door.tile_id -= 1
