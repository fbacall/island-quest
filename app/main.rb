require 'lib/tiled/tiled.rb'

def tick(args)
  if args.state.tick_count.zero?
    map = Tiled::Map.new('maps/world.tmx')
    map.load
    args.state.map = map
    target = args.render_target(:map)
    attributes = map.attributes
    puts attributes.inspect
    target.width = attributes.width.to_i * attributes.tilewidth.to_i
    target.height = attributes.height.to_i * attributes.tileheight.to_i
    target.sprites << map.layers.at(0).sprites
    target.sprites << map.layers.at(1).sprites

    args.state.player.x = 1600 / 2
    args.state.player.y = 1600 / 2
    args.state.player.x_vel = 0
    args.state.player.y_vel = 0
  end

  args.state.player.x_vel = 0
  args.state.player.y_vel = 0
  args.state.player.x_vel = -1 if args.inputs.keyboard.key_held.a
  args.state.player.x_vel = 1 if args.inputs.keyboard.key_held.d
  args.state.player.y_vel = 1 if args.inputs.keyboard.key_held.w
  args.state.player.y_vel = -1 if args.inputs.keyboard.key_held.s

  args.state.player.x = (args.state.player.x + args.state.player.x_vel).clamp(0, 1600 - 16)
  args.state.player.y = (args.state.player.y + args.state.player.y_vel).clamp(0, 1600 - 16)

  unless args.state.map.nil?
    tile_x = (args.state.player.x / 16).floor
    tile_y = (args.state.map.attributes.height.to_i - 1) - (args.state.player.y / 16).floor
    tile = args.state.map.layers.at(0).tile_at(tile_x, tile_y)
    args.outputs.labels << [
      10,
      710,
      "Tile1: #{tile_x} #{tile_y}"
    ]
    args.outputs.labels << [
      10,
      680,
      "Tile1: #{tile.inspect[0..100]}"
    ]
    args.outputs.labels << [
      10,
      650,
      "Tile1: #{tile.inspect[100..200]}"
    ]
    tile = args.state.map.layers.at(1).tile_at(tile_x, tile_y)
    args.outputs.labels << [
      10,
      620,
      "Tile2: #{tile_x} #{tile_y}"
    ]
    args.outputs.labels << [
      10,
      590,
      "Tile2: #{tile.inspect[0..100]}"
    ]
    args.outputs.labels << [
      10,
      560,
      "Tile2: #{tile.inspect[100..200]}"
    ]
    args.outputs.labels << [
      20,
      320,
      "Player: #{args.state.player.x} #{args.state.player.y}"
    ]
  end

  player_draw_x = args.grid.center_x - 8
  player_draw_x = args.state.player.x if args.state.player.x < args.grid.center_x - 8
  player_draw_x = args.grid.center_x + (args.state.player.x - (1600 - args.grid.center_x)) if args.state.player.x > (1600 - (args.grid.center_x + 8))
  player_draw_y = args.grid.center_y - 8
  player_draw_y = args.state.player.y if args.state.player.y < args.grid.center_y - 8
  player_draw_y = args.grid.center_y + (args.state.player.y - (1600 - args.grid.center_y)) if args.state.player.y > (1600 - (args.grid.center_y + 8))
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

  args.outputs.sprites << [map_x, map_y, 1600, 1600, :map]
  args.outputs.sprites << [player_draw_x, player_draw_y, 16, 16, 'man.png']
end
