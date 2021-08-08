class PlayState < State
  def handle_input(args)
    player.x_accel = 0
    player.y_accel = 0
    player.y_accel = 1 if args.inputs.up
    player.x_accel = -1 if args.inputs.left
    player.y_accel = -1 if args.inputs.down
    player.x_accel = 1 if args.inputs.right
    args.state.debug = !args.state.debug if args.inputs.keyboard.key_down.one
    player.noclip = !player.noclip if args.inputs.keyboard.key_down.two
    (camera.zoom -= 1) if args.inputs.keyboard.key_down.open_square_brace && camera.zoom > 1
    (camera.zoom += 1) if args.inputs.keyboard.key_down.close_square_brace && camera.zoom < 10
    push_state(PausedState.new) if args.inputs.keyboard.key_down.escape
    if args.state.debug
      push_state(ScriptState.new('intro')) if args.inputs.keyboard.key_down.i
      push_state(ScriptState.new('async_test')) if args.inputs.keyboard.key_down.p
    end
    if player.interactable && (args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space)
      if player.interactable.respond_to?(:interact)
        player.interactable.interact
      else
        puts player.interactable.inspect
      end
    end
  end

  def update(args)
    player.tick
  end

  def draw(args)
    draw_debug(args) if args.state.debug

    entities = [player]
    entities.concat(map.layers)
    entities.concat(map.objects)
    entities.sort! { |a,b| a.z_index <=> b.z_index }.map!(&:draw)

    # Ocean background
    args.outputs.solids << {
      x: 0, y: 0,
      w: args.grid.w,
      h: args.grid.h,
      r: 184,
      g: 253,
      b: 255
    }
    args.outputs.sprites << entities

    if player.interactable && !@paused
      args.outputs.sprites << TileEntity.new(tile_id: 242, x: player.x, y: player.y + 16, z_index: 500).draw
    end

    bg = TileEntity.new(tile_id: 241)
    player.inventory.each_with_index do |item, i|
      args.outputs.sprites << bg.inventory_draw(i)
      args.outputs.sprites << item.inventory_draw(i)
    end
  end

  # Stop footstep sounds
  def pause
    super
    $gtk.args.audio[:footstep][:paused] = true if $gtk.args.audio[:footstep]
    $gtk.args.audio[:plane_engine][:paused] = true if $gtk.args.audio[:plane_engine]
  end

  private

  def draw_debug(args)
    tile_x, tile_y = map.tile_coords(player.x, player.y)
    tile1, tile2 = map.tiles_at(player.x, player.y)
    args.outputs.labels << [10, 70, "Tile: #{tile_x} #{tile_y} [Layer 1: #{tile1.id}] [Layer 2: #{tile2.id}] [T: #{tile1.properties[:terrain]}", -1]
    args.outputs.labels << [10, 30, player.debug_info, -1]
    args.outputs.lines << [0, args.grid.h.half, args.grid.w, args.grid.h.half, 255, 255, 255, 255]
    args.outputs.lines << [args.grid.w.half, 0, args.grid.w.half, args.grid.h, 255, 255, 255, 255]
    args.outputs.labels << [10, 310, "Camera: #{camera.target_x.round(1)}, #{camera.target_y.round(1)}, Adjusted: #{camera.adjusted_x.round(1)}, #{camera.adjusted_y.round(1)}, Target: #{camera.target}", -1]
    args.outputs.primitives << args.gtk.framerate_diagnostics_primitives
  end
end
