class PausedState < State
  def handle_input(args)
    pop_state if args.inputs.keyboard.key_down.p
  end

  def draw(args)
    previous_state&.draw(args)
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
