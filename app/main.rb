require 'lib/tiled/tiled.rb'
require 'app/player.rb'
require 'app/layer.rb'
require 'app/map.rb'

def tick(args)
  debug = true
  args.state.game_scale ||= 2
  if args.state.tick_count.zero?
    args.state.map = Map.new('maps/world.tmx')
    args.state.player = Player.new(args.state.map.w.half, args.state.map.h.half)
  end

  # Controls
  args.state.player.x_accel = 0
  args.state.player.y_accel = 0
  args.state.player.x_accel = -1 if args.inputs.keyboard.key_held.a
  args.state.player.x_accel = 1 if args.inputs.keyboard.key_held.d
  args.state.player.y_accel = 1 if args.inputs.keyboard.key_held.w
  args.state.player.y_accel = -1 if args.inputs.keyboard.key_held.s

  args.state.player.tick

  if debug
    draw_debug(args)
  end

  args.outputs.sprites << (args.state.map.layers + [args.state.player]).sort_by(&:z_index)
end

def draw_debug(args)
  unless args.state.map.nil?
    tile_x = (args.state.player.x_pos / 16).round
    tile_y = (args.state.map.attributes.height.to_i - 1) - (args.state.player.y_pos / 16).round
    tile1 = args.state.map.tile_at(tile_x, tile_y, 0)
    tile2 = args.state.map.tile_at(tile_x, tile_y, 1)
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
