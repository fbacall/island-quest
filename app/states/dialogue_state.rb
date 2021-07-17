class DialogueState < State
  def initialize(script, participants = {}, variables = {})
    @script = $gtk.parse_json($gtk.read_file("dialogue/#{script}.json"))
    @participants = participants
    @variables = variables
  end

  def init
    super
    @tick = $gtk.args.tick_count
    @sections = { top: nil, middle: nil, bottom: nil }
    reset
    @speech_index = -1
    @segment_index = -1
    @delay = 0
    @speed = 4
  end

  def reset(pos = nil)
    (pos ? [pos.to_sym] : @sections.keys).each do |p|

      @sections[p] = {
        text: nil,
        sprite: nil,
        active: false
      }
    end
  end

  def activate(pos = :middle)
    reset(pos)
    @sections.transform_values { |v| v[:active] = false }
    @sections[pos.to_sym][:active] = true
  end

  def set_actor(actor, pos = :middle)
    @sections[pos.to_sym][:sprite] = @participants[actor] if actor
  end

  def push_char(char, pos = :middle)
    @sections[pos.to_sym][:text] ||= ''
    @sections[pos.to_sym][:text] << char
  end

  def handle_input(args)
    @speed = 4
    if args.inputs.keyboard.key_held.shift
      @speed = 1
      @delay = 0
    end
    scroll(-1) if args.inputs.keyboard.key_down.w
    scroll(1) if args.inputs.keyboard.key_down.s
    resume if @paused && (args.inputs.keyboard.key_down.space || args.inputs.keyboard.key_down.enter)
  end

  def scroll(direction)
  end

  def update(args)
    return if @paused

    if @speech_index == -1
      next_segment
    elsif @delay > 0
      @delay -= 1
    elsif (args.tick_count * 7) % @speed == 0 # Add some pseudo-randomness to dialogue speed
      next_char
    end
  end

  def next_segment
    @segment_index += 1
    if @segment_index >= @script.length
      pop_state
    else
      @segment = @script[@segment_index]
      @segment['speech'] = substitute(@segment['speech'])
      activate(@segment['pos'])
      set_actor(@segment['actor'], @segment['pos'])
      next_char
    end
  end

  def next_char
    @speech_index += 1
    if @speech_index >= @segment['speech'].length
      @speech_index = -1
      pause
    else
      char = @segment['speech'][@speech_index]
      pos = @segment['pos']
      case char
      when ','
        @delay = 15
      when '.'
        @delay = 25
      when *%w(- : ; " ' \n \t \s)
      else
        $gtk.args.audio[:talk] = { input: 'sounds/talk.wav' }
      end
      push_char(char, pos)
    end
  end

  def draw(args)
    text_size = 18
    text_width, text_height = $gtk.calcstringbox('A', text_size)
    third_height = (args.grid.h / 3).to_i
    avatar_width = 200
    max_chars = ((args.grid.w - avatar_width - (3 * text_width)) / text_width).floor
    max_lines = (third_height / text_height).floor

    previous_state&.draw(args)
    @sections.each do |pos, data|
      avatar_x = 0
      avatar_y = text_height
      offset_x = 0
      offset_y = 0
      text_x = data[:sprite] ? 0 + avatar_width + text_width : 0
      text_y = offset_y
      flip = false
      align = 0
      case pos
      when :top
        offset_x = args.grid.w
        offset_y = third_height * 2
        avatar_x = args.grid.w - avatar_width - (2 * text_width)
        avatar_y = third_height * 2 + text_height
        text_x = data[:sprite] ? avatar_x - text_width : offset_x
        text_y = offset_y
        flip = true
        align = 2
      when :middle
        offset_x = args.grid.w.half
        offset_y = third_height
        text_x = offset_x
        text_y = offset_y
        align = 1
      end

      if data[:text]
        a = data[:active] ? 180 : 128
        args.outputs.primitives << { x: 0, y: offset_y, w: args.grid.w, h: third_height, r: 0, g: 0, b: 0, a: a }.solid
      end

      if data[:sprite]
        args.outputs.primitives << {
          x: avatar_x,
          y: avatar_y,
          a: data[:active] ? 255 : 128,
          flip_horizontally: flip
        }.merge(data[:sprite].dialogue_avatar)
      end

      if data[:text] && data[:text].length > 0
        a = data[:active] ? 255 : 160
        args.string.wrapped_lines(data[:text], max_chars).each_with_index do |line, i|
          args.outputs.labels << {
            x: text_x,
            y: text_y + text_height * (max_lines - i),
            text: line,
            size_enum: text_size,
            alignment_enum: align,
            r: 255,
            g: 255,
            b: 255,
            a: a
          }
        end
      end

      if data[:active]
        if @paused
          s = 64
          phase = Math.sin(args.tick_count / 4) * s
          col = 255 - s + phase
          args.outputs.labels << {
            x: args.grid.w.half,
            y: offset_y + text_height,
            text: 'Continue',
            size_enum: text_size,
            alignment_enum: 1,
            r: col,
            g: col,
            b: col,
            a: 255
          }
        end
      end
    end
  end

  private

  def substitute(speech)
    str = ''
    parts = speech.split('%{')
    str << parts.first
    parts[1..-1].each do |part|
      var, text = part.split('}')
      str << @variables[var.to_sym] + text
    end
    str
  end
end
