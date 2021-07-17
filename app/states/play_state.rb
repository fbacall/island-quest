class PlayState < State
  def init
    super
    camera ||= Camera.new(800, 800).tap do |c|
      c.scale = 4
      c.track(player)
    end
    #push_state(DialogueState.new('intro', 'player' => player))
  end

  def handle_input(args)
    player.x_accel = 0
    player.y_accel = 0
    player.y_accel = 1 if args.inputs.keyboard.key_held.w
    player.x_accel = -1 if args.inputs.keyboard.key_held.a
    player.y_accel = -1 if args.inputs.keyboard.key_held.s
    player.x_accel = 1 if args.inputs.keyboard.key_held.d
    args.state.debug = !args.state.debug if args.inputs.keyboard.key_down.one
    (camera.scale -= 1) if args.inputs.keyboard.key_down.open_square_brace && camera.scale > 1
    (camera.scale += 1) if args.inputs.keyboard.key_down.close_square_brace && camera.scale < 10
    push_state(PausedState.new) if args.inputs.keyboard.key_down.escape
    push_state(DialogueState.new('intro', 'player' => player)) if args.inputs.keyboard.key_down.i
    push_state(ScriptState.new('test')) if args.inputs.keyboard.key_down.x
    if args.state.interactable&.interactable? &&  args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space
      if args.state.interactable.respond_to?(:interact)
        args.state.interactable.interact
      else
        puts args.state.interactable.inspect
      end
    end
  end

  def update(args)
    args.state.interactable = nil
    player.tick
    args.state.interactable = map.objects.detect do |obj|
      obj.intersect_rect?(player)
    end
  end

  def draw(args)
    draw_debug(args) if args.state.debug

    args.outputs.sprites << (map.layers + map.objects + [player]).sort_by(&:z_index).map(&:draw).compact

    if args.state.interactable&.interactable?
      args.outputs.sprites << TileEntity.new(242, x: player.x, y: player.y + 16, z_index: 500).draw
    end

    bg = TileEntity.new(241)
    player.inventory.each_with_index do |item, i|
      args.outputs.sprites << bg.inventory_draw(i)
      args.outputs.sprites << item.inventory_draw(i)
    end

  end

  # Stop footstep sounds
  def pause
    super
    $gtk.args.audio[:footstep][:paused] = true if $gtk.args.audio[:footstep]
  end

  private

  def draw_debug(args)
    tile_x, tile_y = map.tile_coords(player.x, player.y)
    tile1, tile2 = map.tiles_at(player.x, player.y)
    args.outputs.labels << [10, 70, "Tile: #{tile_x} #{tile_y} [Layer 1: #{tile1.id}] [Layer 2: #{tile2.id}] [T: #{tile1.properties[:terrain]}", -1]
    args.outputs.labels << [10, 30, player.debug_info, -1]
    args.outputs.labels << [args.grid.w - 80, args.grid.h - 10, 'FPS: ' + $gtk.current_framerate.round(1).to_s, -1]
    args.outputs.lines << [0, args.grid.h.half, args.grid.w, args.grid.h.half, 255, 255, 255, 255]
    args.outputs.lines << [args.grid.w.half, 0, args.grid.w.half, args.grid.h, 255, 255, 255, 255]
    args.outputs.labels << [10, 310, "Camera: #{camera.target_x.round(1)}, #{camera.target_y.round(1)}, Adjusted: #{camera.adjusted_x.round(1)}, #{camera.adjusted_y.round(1)}, Target: #{camera.target}", -1]
  end
end
