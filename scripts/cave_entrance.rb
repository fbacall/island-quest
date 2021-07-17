fade_out
e = get_entity('cave_exit')
player.x = e.x
player.y = e.y
fade_in
move(player, player.x, player.y - 16)
