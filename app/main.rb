require 'lib/tiled/tiled.rb'

def tick(args)
  game_scale = 2
  if args.state.tick_count.zero?
    map = Tiled::Map.new('maps/world.tmx')
    map.load
    args.state.map = map

    attributes = map.attributes
    args.state.world.w = attributes.width.to_i * attributes.tilewidth.to_i
    args.state.world.h = attributes.height.to_i * attributes.tileheight.to_i
    puts attributes.inspect
    layer1 = args.render_target(:layer1)
    layer1.width = args.state.world.w
    layer1.height = args.state.world.h
    layer1.sprites << map.layers.at(0).sprites
    layer2 = args.render_target(:layer2)
    layer2.width = args.state.world.w
    layer2.height = args.state.world.h
    layer2.sprites << map.layers.at(1).sprites

    args.state.player.x = args.state.world.w.half
    args.state.player.y = args.state.world.h.half
    args.state.player.w = 16
    args.state.player.h = 16
    args.state.player.x_vel = 0
    args.state.player.y_vel = 0
    args.state.player.x_accel = 0
    args.state.player.y_accel = 0
  end

  max_speed = 3
  max_accel = 0.8
  friction = 0.25

  # Acceleration
  args.state.player.x_accel = 0
  args.state.player.y_accel = 0
  args.state.player.x_accel = -1 if args.inputs.keyboard.key_held.a
  args.state.player.x_accel = 1 if args.inputs.keyboard.key_held.d
  args.state.player.y_accel = 1 if args.inputs.keyboard.key_held.w
  args.state.player.y_accel = -1 if args.inputs.keyboard.key_held.s
  args.state.player.x_accel, args.state.player.y_accel = normalise(args.state.player.x_accel, args.state.player.y_accel, max_accel)

  # Velocity
  args.state.player.x_vel += args.state.player.x_accel
  args.state.player.y_vel += args.state.player.y_accel
  if mag(args.state.player.x_vel, args.state.player.y_vel) > max_speed
    args.state.player.x_vel, args.state.player.y_vel = normalise(args.state.player.x_vel, args.state.player.y_vel, max_speed)
  end

  # Friction
  fric_x, fric_y = normalise(args.state.player.x_vel, args.state.player.y_vel, friction)
  if fric_x.abs < args.state.player.x_vel.abs
    args.state.player.x_vel -= fric_x
  else
    args.state.player.x_vel = 0
  end
  if fric_y.abs < args.state.player.y_vel.abs
    args.state.player.y_vel -= fric_y
  else
    args.state.player.y_vel = 0
  end

  # Position
  tile_x = (args.state.player.x / 16).round
  tile_y = (args.state.map.attributes.height.to_i - 1) - (args.state.player.y / 16).round
  tile1 = args.state.map.layers.at(0).tile_at(tile_x, tile_y)
  tile2 = args.state.map.layers.at(1).tile_at(tile_x, tile_y)
  next_x = (args.state.player.x + args.state.player.x_vel).clamp(args.state.player.w.half, 1600 - args.state.player.w.half)
  next_y = (args.state.player.y + args.state.player.y_vel).clamp(args.state.player.h.half, 1600 - args.state.player.h.half)
  next_tile1 = args.state.map.layers.at(0).tile_at((next_x / 16).round, (args.state.map.attributes.height.to_i - 1) - (next_y / 16).round)
  next_tile2 = args.state.map.layers.at(1).tile_at((next_x / 16).round, (args.state.map.attributes.height.to_i - 1) - (next_y / 16).round)
  if tile_x == next_x || (next_tile1.attributes.id < 3 && next_tile2.nil?)
    args.state.player.x = next_x
  end

  if tile_y == next_y || (next_tile1.attributes.id < 3 && next_tile2.nil?)
    args.state.player.y = next_y
  end

  unless args.state.map.nil?

    args.outputs.labels << [
      10,
      710,
      "Tile1: #{tile_x} #{tile_y}"
    ]
    args.outputs.labels << [
      10,
      680,
      "Tile1: #{tile1.inspect[0..100]}"
    ]
    args.outputs.labels << [
      10,
      650,
      "Tile1: #{tile1.inspect[100..200]}"
    ]
    args.outputs.labels << [
      10,
      590,
      "Tile2: #{tile2.inspect[0..100]}"
    ]
    args.outputs.labels << [
      10,
      560,
      "Tile2: #{tile2.inspect[100..200]}"
    ]
    args.outputs.labels << [
      20,
      320,
      "Player: #{args.state.player.x} #{args.state.player.y}, Speed: #{args.state.player.x_vel} #{args.state.player.y_vel}, Accel: #{args.state.player.x_accel} #{args.state.player.y_accel}"
    ]
  end

  camera_center_x = args.grid.center_x / game_scale
  camera_center_y = args.grid.center_y / game_scale

  player_draw_x = camera_center_x
  player_draw_x = args.state.player.x if args.state.player.x < camera_center_x
  player_draw_x = camera_center_x + (args.state.player.x - (args.state.world.w - camera_center_x)) if args.state.player.x > (args.state.world.w - camera_center_x)
  player_draw_y = camera_center_y
  player_draw_y = args.state.player.y if args.state.player.y < camera_center_y
  player_draw_y = camera_center_y + (args.state.player.y - (args.state.world.h - camera_center_y)) if args.state.player.y > (args.state.world.h - camera_center_y)
  args.outputs.labels << [
    20,
    210,
    "Player Draw: #{player_draw_x} #{player_draw_y}"
  ]
  map_x = player_draw_x - args.state.player.x
  #map_x = args.grid.center_x if map_x < args.grid.center_x || map_x > (1600 - args.grid.center_x)
  map_y = player_draw_y - args.state.player.y
  #map_y = args.grid.center_y if map_y < args.grid.center_y || map_y > (1600 - args.grid.center_y)
  args.outputs.labels << [
    20,
    240,
    "Map: #{map_x} #{map_y}"
  ]

  args.outputs.sprites << [map_x * game_scale, map_y * game_scale, args.state.world.w * game_scale, args.state.world.h * game_scale, :layer1]
  args.outputs.sprites << [player_draw_x * game_scale, player_draw_y * game_scale, args.state.player.w * game_scale, args.state.player.h * game_scale, 'man.png']
  args.outputs.sprites << [map_x * game_scale, map_y * game_scale, args.state.world.w * game_scale, args.state.world.h * game_scale, :layer2]
end

def mag(x, y)
  Math.sqrt((x ** 2).abs + (y ** 2).abs)
end

def normalise(x, y, factor = 1)
  m = mag(x, y)
  return [0, 0] if m == 0
  [x * factor / m, y * factor / m]
end
