class MenuState < State
  def init
    super
    $gtk.args.state.menu_option ||= 0
  end

  def handle_input(args)
    change_option(1) if args.inputs.keyboard.key_down.s
    change_option(-1) if args.inputs.keyboard.key_down.w
    if args.inputs.keyboard.key_down.enter || args.inputs.keyboard.key_down.space
      $gtk.args.audio[:select] = { input: 'sounds/select.wav' }
      handle_option(@options[$gtk.args.state.menu_option])
    end
  end

  def handle_option(option)
  end

  def change_option(dir)
    ($gtk.args.state.menu_option += dir).clamp(0, @options.length - 1)
    $gtk.args.audio[:menu] = { input: 'sounds/menu.wav' }
  end

  def draw(args)
    previous_state&.draw(args)
    args.outputs.primitives << { x: 0, y: 0, w: args.grid.w, h: args.grid.h, r: 0, g: 0, b: 0, a: 128 }.solid

    # BG
    args.outputs.solids << {
      x: 0,
      y: 0,
      w: args.grid.w,
      h: args.grid.h,
      r: 32,
      g: 126,
      b: 255,
      a: 255
    }

    # Options
    s = 64
    phase = Math.sin(args.tick_count / 4) * s
    @options.each_with_index do |opt, i|
      col = $gtk.args.state.menu_option == i ? (255 - s + phase) : 192
      args.outputs.labels << {
        x: args.grid.center_x,
        y: 400 - (i * 48),
        text: opt,
        size_enum: 20,
        alignment_enum: 1,
        r: col,
        g: col,
        b: col,
        a: 255
      }

      # Title
      char_spacing = 40
      offset_x = args.grid.center_x - (@title.length * char_spacing) / 2
      @title.chars.each_with_index do |char, i|
        p = Math.sin((args.tick_count + i * 3)/ 32) * 30
        args.outputs.labels << {
          x: offset_x + (char_spacing * i),
          y: 680 + p,
          text: char,
          size_enum: 40,
          alignment_enum: 0,
          r: 255,
          g: 255,
          b: 255,
          a: 255
        }
      end
    end
  end
end
