class ScriptState < State
  def initialize(script)
    @script = $gtk.read_file("scripts/#{script}.rb")
  end

  def init
    super
    @fiber = Fiber.new do
      ScriptContext.new(@script).run
    end
  end

  def update(args)
    return if @paused

    if @fiber.alive?
      @fiber.resume
    else
      pop_state
    end
  end

  def draw(args)
    previous_state&.draw(args)
  end
end
