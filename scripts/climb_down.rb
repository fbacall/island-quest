stop(player)
fade_out
4.times do
  play_sound('thud')
  wait
end
e = get_entity('climb_up')
player.x = e.x
player.y = e.y - 16
fade_in
move(player, player.x, player.y - 8)
