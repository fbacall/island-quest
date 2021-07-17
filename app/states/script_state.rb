class ScriptState < State
  def initialize(script, entity = nil)
    @script = $gtk.read_file("scripts/#{script}.rb")
    @entity = entity
  end

  def init
    super
    @fiber = Fiber.new do
      ScriptContext.new(@script, @entity).run
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
