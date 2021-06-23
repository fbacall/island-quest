require 'lib/tiled/tiled.rb'
require 'app/player.rb'
require 'app/map_layer.rb'
require 'app/map.rb'

def tick(args)
  args.state.debug = false if args.state.debug.nil? # Can't use `||=` because the value can be `false`
  args.state.game_scale ||= 3
  if args.state.tick_count.zero?
    args.state.map = Map.new('maps/world.tmx')
    args.state.player = Player.new(args.state.map.w.half, args.state.map.h.half)
  end

  # Controls
  args.state.player.x_accel = 0
  args.state.player.y_accel = 0
  args.state.player.y_accel = 1 if args.inputs.keyboard.key_held.w
  args.state.player.x_accel = -1 if args.inputs.keyboard.key_held.a
  args.state.player.y_accel = -1 if args.inputs.keyboard.key_held.s
  args.state.player.x_accel = 1 if args.inputs.keyboard.key_held.d
  args.state.debug = !args.state.debug if args.inputs.keyboard.key_down.one
  (args.state.game_scale -= 1) if args.inputs.keyboard.key_down.open_square_brace && args.state.game_scale > 1
  (args.state.game_scale += 1) if args.inputs.keyboard.key_down.close_square_brace && args.state.game_scale < 5

  args.state.player.tick

  draw_debug(args) if args.state.debug

  args.outputs.sprites << (args.state.map.layers + [args.state.player]).sort_by(&:z_index)
end

def draw_debug(args)
  tile_x, tile_y = args.state.map.tile_coords(args.state.player.x_pos, args.state.player.y_pos)
  tile1, tile2 = args.state.map.tiles_at(args.state.player.x_pos, args.state.player.y_pos)
  args.outputs.labels << [10, 70, "Tile: #{tile_x} #{tile_y} [Layer 1: #{tile1.id}] [Layer 2: #{tile2.id}]", -1]
  args.outputs.labels << [10, 30, args.state.player.debug_info, -1]
end
