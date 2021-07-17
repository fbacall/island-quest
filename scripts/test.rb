def report
  puts "Player is at: #{player.x}, #{player.y}"
end

puts "Script begin"

player_x, player_y = player.x, player.y

move(player, player_x + 50, player_y + 50)
report
move(player, player_x, player_y + 100)
report

puts "Script mid"
start_dialogue('intro')

move(player, player_x, player_y + 50)
report
move(player, player_x, player_y)
report

puts "Script end"
