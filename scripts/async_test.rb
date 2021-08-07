stop(player)
gob = get_entity('gob')
ox, oy = player.x, player.y
gx, gy = gob.x, gob.y

gob.x, gob.y = ox, oy + 16
gob.visible = true
player.noclip = true
z = camera.zoom
3.times do
  async do
    zoom_to(1, 120)
    move(player, ox + 32, oy)
    move(gob, ox - 32, oy + 16)
  end
  puts "Player: #{player.x}, #{player.y}"
  puts "Gob: #{gob.x}, #{gob.y}"

  async do
    move(player, ox + 32, oy - 32)
    move(gob, ox - 32, oy - 16)
  end
  puts "Player: #{player.x}, #{player.y}"
  puts "Gob: #{gob.x}, #{gob.y}"

  async do
    zoom_to(z, 120)
    move(player, ox, oy - 32)
    move(gob, ox, oy - 16)
  end
  puts "Player: #{player.x}, #{player.y}"
  puts "Gob: #{gob.x}, #{gob.y}"
end

gob.visible = false
gob.x, gob.y = gx, gy
player.noclip = false

dialogue(:middle, 'Done')