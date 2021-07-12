def report
  puts "Player is at: #{player.x_pos}, #{player.y_pos}"
end

puts "Script begin"

player_x, player_y = player.x_pos, player.y_pos

move(player, player_x + 50, player_y + 50)
report
move(player, player_x, player_y + 100)
report

puts "Script mid"
start_dialogue('yes')

move(player, player_x, player_y + 50)
report
move(player, player_x, player_y)
report

puts "Script end"
