class Dialogue
  attr_accessor :speed, :delay, :active
  attr_reader :speech, :entity, :text

  def initialize(speech, entity = nil)
    @speech_index = -1
    @delay = 0
    @speech = speech
    @entity = entity
    @speed = 4
    @done = false
    @text = ''
    @active = true
  end

  def tick
    return if done?

    if @delay > 0
      @delay -= 1
    elsif ($gtk.args.tick_count * 7) % @speed == 0 # Add some pseudo-randomness to dialogue speed
      next_char
    end
  end

  def next_char
    @speech_index += 1
    if @speech_index >= speech.length
      @done = true
    else
      char = speech[@speech_index]
      case char
      when '.'
        @delay = 15
      when *%w(- : ; " ' \n \t \s)
      else
        $gtk.args.audio[:talk] = { input: 'sounds/talk.wav', pitch: @entity ? @entity.voice_pitch : 1.0 }
      end
      @text += char
    end
  end

  def draw(pos)
    args = $gtk.args
    third_height = args.grid.h.third
    case pos
    when :top
      offset = third_height * 2
    when :middle
      offset = third_height
    when :bottom
      offset = 0
    end

    text_size = 14
    text_width, text_height = $gtk.calcstringbox('A', text_size)
    avatar_width = 200
    margin = 20
    max_chars = ((args.grid.w - avatar_width - (2 * margin)) / text_width).floor
    max_lines = (third_height / text_height).floor

    avatar_x = 0
    avatar_y = margin + offset
    offset_y = offset
    text_x = entity ? avatar_width : 0
    text_y = offset_y
    flip = false
    text_align = 0

    if pos == :middle
      # No avatar for middle
      avatar_x = -8192
      text_x = args.grid.w.half
      text_align = 1
    elsif pos == :top
      avatar_x = args.grid.w - avatar_width
      text_x = @entity ? avatar_x - margin : args.grid.w - margin
      flip = true
      text_align = 2
    end

    if @text.length > 0
      a = @active ? 180 : 128
      args.outputs.primitives << { x: 0, y: offset_y, w: args.grid.w, h: third_height, r: 0, g: 0, b: 0, a: a }.solid
    end

    if @entity
      args.outputs.primitives << {
        x: avatar_x,
        y: avatar_y,
        a: @active ? 255 : 128,
        flip_horizontally: flip
      }.merge!(@entity.dialogue_avatar)
    end

    if @text.length > 0
      a = @active ? 255 : 160
      args.string.wrapped_lines(@text, max_chars).each_with_index do |line, i|
        args.outputs.labels << {
          x: text_x,
          y: text_y + text_height * (max_lines - i),
          text: line,
          size_enum: text_size,
          alignment_enum: text_align,
          r: 255,
          g: 255,
          b: 255,
          a: a
        }
      end
    end

    if @active
      if @done
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

  def done?
    @done
  end
end
