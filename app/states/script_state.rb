class ScriptState < State
  BAR_HEIGHT = 48
  TRANSITION_TICKS = 16

  def initialize(script, entity = nil)
    @script = script
    @entity = entity
    @done = false
    @transition_length = TRANSITION_TICKS
  end

  def init
    super
    code = $gtk.read_file(script_path)

    @fiber = Fiber.new do
      if code
        ScriptContext.new(code, @entity).run
      else
        $gtk.notify! "Missing script: #{script_path}"
      end
    end
  end

  def update(args)
    return if @paused

    if @transition_length > 0
      @transition_length -= 1
    else
      if @fiber.alive?
        @fiber.resume
      elsif @done
        pop_state
      else
        @done = true
        @transition_length = TRANSITION_TICKS
      end
    end
  end


  def draw(args)
    # Letterboxing transition
    letterbox_height = BAR_HEIGHT * ((@done ? 0 : 1) - (@transition_length / TRANSITION_TICKS)).abs
    args.outputs.primitives << { x: 0, y: 0, w: args.grid.w, h: letterbox_height, r: 0, g: 0, b: 0 }.solid
    args.outputs.primitives << { x: 0, y: args.grid.h - letterbox_height, w: args.grid.w, h: letterbox_height, r: 0, g: 0, b: 0 }.solid
    previous_state&.draw(args)
  end

  private

  def script_path
    "scripts/#{@script}.rb"
  end
end
