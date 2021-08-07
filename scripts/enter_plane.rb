if has_item?('fuel')
  stop(player)
  fade_out

  3.times do
    play_sound('jump')
    wait
  end
  dialogue(:middle, 'Refueled the plane!')
  fade_in
  clear_dialogue

  plane = get_entity('plane')
  witch = get_entity('witch')
  gob = get_entity('gob')

  player.noclip = true
  plane.noclip = true
  move(player, plane.x - 48, plane.y + 16)
  plane.z_index = 9001
  move(player, plane.x, plane.y + 16)
  move(player, plane.x, plane.y)

  fade_out
  player.visible = false
  plane.state = 'occupied'
  camera.track(plane)
  fade_in

  plane.revs = 6
  tick(plane, 120)
  plane.revs = 20
  tick(plane, 120)
  plane.revs = 40
  tick(plane, 120)
  plane.revs = 60
  tick(plane, 120)

  plane.revs = 80
  move(plane, 1280, 1408)

  async do
    zoom_to(3, 240)
    plane.revs = 90
    move(plane, 880, 1232)
    door = get_entity('hut_door')
    play_sound('open')
    door.tile_id += 1
    gob.visible = true
    move(gob, door.x, door.y - 8)
    face(gob, plane, 240)
  end

  async do
    zoom_to(2, 240)
    plane.revs = 100
    move(plane, 320, 1056)
    door = get_entity('house_door')
    play_sound('open')
    door.tile_id += 1
    witch.visible = true
    move(witch, door.x, door.y - 8)
    face(gob, plane, 120)
    face(witch, plane, 360)
  end

  async do
    zoom_to(1, 120)
    move(plane, -64, 960)
    fade_out(240)
    face(witch, plane, 120)
    face(gob, plane, 240)
  end

  plane.revs = 0
  plane.tick

  dialogue(:middle, 'You escaped the island!')
  dialogue(:middle, 'Thanks for playing!')

  $gtk.args.gtk.request_quit
else
  dialogue(:bottom, "Hmm, doesn't look like there's any fuel left.", player)
end
