require 'lib/tiled/tiled.rb'
require 'app/player.rb'

def tick(args)
  debug = true
  args.state.game_scale ||= 2
  if args.state.tick_count.zero?
    map = Tiled::Map.new('maps/world.tmx')
    map.load
    args.state.map = map

    attributes = map.attributes
    args.state.world.w = attributes.width.to_i * attributes.tilewidth.to_i
    args.state.world.h = attributes.height.to_i * attributes.tileheight.to_i
    layer1 = args.render_target(:layer1)
    layer1.width = args.state.world.w
    layer1.height = args.state.world.h
    layer1.sprites << map.layers.at(0).sprites
    layer2 = args.render_target(:layer2)
    layer2.width = args.state.world.w
    layer2.height = args.state.world.h
    layer2.sprites << map.layers.at(1).sprites

    args.state.player = Player.new(args.state.world.w.half, args.state.world.h.half)
  end

  args.state.player.x_accel = 0
  args.state.player.y_accel = 0
  args.state.player.x_accel = -1 if args.inputs.keyboard.key_held.a
  args.state.player.x_accel = 1 if args.inputs.keyboard.key_held.d
  args.state.player.y_accel = 1 if args.inputs.keyboard.key_held.w
  args.state.player.y_accel = -1 if args.inputs.keyboard.key_held.s

  args.state.player.tick

  # Position
  tile_x = (args.state.player.x_pos / 16).round
  tile_y = (args.state.map.attributes.height.to_i - 1) - (args.state.player.y_pos / 16).round
  next_x = (args.state.player.x_pos + args.state.player.x_vel).clamp(args.state.player.w.half, args.state.world.w - args.state.player.w.half)
  next_y = (args.state.player.y_pos + args.state.player.y_vel).clamp(args.state.player.h.half, args.state.world.h - args.state.player.h.half)
  next_tile1 = args.state.map.layers.at(0).tile_at((next_x / 16).round, (args.state.map.attributes.height.to_i - 1) - (next_y / 16).round)
  next_tile2 = args.state.map.layers.at(1).tile_at((next_x / 16).round, (args.state.map.attributes.height.to_i - 1) - (next_y / 16).round)
  if tile_x == next_x || (next_tile1.attributes.id < 3 && next_tile2.nil?)
    args.state.player.x_pos = next_x
  else
    args.state.player.x_vel = args.state.player.x_vel * -2
  end

  if tile_y == next_y || (next_tile1.attributes.id < 3 && next_tile2.nil?)
    args.state.player.y_pos = next_y
  else
    args.state.player.y_vel = args.state.player.y_vel * -2
  end

  if debug
    draw_debug(args)
  end

  map_x = args.state.player.x / args.state.game_scale - args.state.player.x_pos
  map_y = args.state.player.y / args.state.game_scale - args.state.player.y_pos
  args.outputs.sprites << [map_x * args.state.game_scale, map_y * args.state.game_scale, args.state.world.w * args.state.game_scale, args.state.world.h * args.state.game_scale, :layer1]
  args.outputs.sprites << args.state.player
  args.outputs.sprites << [map_x * args.state.game_scale, map_y * args.state.game_scale, args.state.world.w * args.state.game_scale, args.state.world.h * args.state.game_scale, :layer2]
end

def draw_debug(args)
  unless args.state.map.nil?
    tile_x = (args.state.player.x_pos / 16).round
    tile_y = (args.state.map.attributes.height.to_i - 1) - (args.state.player.y_pos / 16).round
    tile1 = args.state.map.layers.at(0).tile_at(tile_x, tile_y)
    tile2 = args.state.map.layers.at(1).tile_at(tile_x, tile_y)
    args.outputs.labels << [
      10,
      70,
      "Tile: #{tile_x} #{tile_y} [Layer 1: #{tile1.id}] [Layer 2: #{tile2.id}]"
    ]
  end

  args.outputs.labels << [
    10,
    30,
    args.state.player.debug_info
  ]
end