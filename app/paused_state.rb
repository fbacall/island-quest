class PausedState
  def init(prev_state)
    @prev_state = prev_state
  end

  def pause
    @paused = true
  end

  def resume
    @paused = false
  end

  def tick(args)
    @prev_state.draw(args)
    args.outputs.solids << { x: 1280 * current_progress, y: 360, w: 10, h: 10 }
  end

  def handle_input(args)
    $state_manager.pop_state if args.inputs.keyboard.key_down.p
  end

  def update(args)
  end

  def draw(args)
    @prev_state.draw(args)
    args.outputs.primitives << { x: 0, y: 0, w: args.grid.w, h: args.grid.h, r: 0, g: 0, b: 0, a: 128 }.solid
    s = 32
    phase = Math.sin(args.tick_count / 16) * s
    args.outputs.labels << { x: args.grid.center_x,
                             y: args.grid.center_y + 32,
                            text: 'Paused',
                            size_enum: 20,
                            alignment_enum: 1,
                            r: 255 - s + phase,
                            g: 255 - s + phase,
                            b: 255 - s + phase,
                            a: 255 - s + phase }
  end
end
