stop(player)
gob = get_entity('gob')
ox, oy = player.x, player.y
gx, gy = gob.x, gob.y

gob.x, gob.y = ox, oy + 16
gob.visible = true
player.noclip = true

3.times do
  async do
    move(player, ox + 32, oy)
    move(gob, ox - 32, oy + 16)
  end

  async do
    move(player, ox + 32, oy - 32)
    move(gob, ox - 32, oy - 16)
  end

  async do
    move(player, ox, oy - 32)
    move(gob, ox, oy - 16)
  end
end

gob.visible = false
gob.x, gob.y = gx, gy
player.noclip = false

dialogue(:middle, 'Done')