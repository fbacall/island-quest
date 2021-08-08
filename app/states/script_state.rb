class ScriptState < State
  attr_reader :dialogue_speed

  def initialize(script, entity = nil)
    @script = script
    @entity = entity
    @active = false
    @dialogue_sections = { top: nil, middle: nil, bottom: nil }
    $gtk.args.state.fade = 0
  end

  def resume
    super
    @active = true
  end

  def init
    push_state(TransitionState.new(:in))
    super
    code = $gtk.read_file(script_path)

    @fiber = Fiber.new do
      if code
        ScriptContext.new(code, @entity, self).run
      else
        $gtk.notify! "Missing script: #{script_path}"
      end
    end
  end

  def update(args)
    return if @paused

    if @fiber.alive?
      @fiber.resume
    else
      pop_state
      push_state(TransitionState.new(:out))
    end
  end

  def draw(args)
    args.outputs.primitives << { x: 0, y: 0, w: args.grid.w, h: args.grid.h, r: 0, g: 0, b: 0, a: args.state.fade }.solid
    previous_state&.draw(args)

    if @active
      args.outputs.primitives << { x: 0, y: 0, w: args.grid.w, h: TransitionState::BAR_HEIGHT, r: 0, g: 0, b: 0 }.solid
      args.outputs.primitives << { x: 0, y: args.grid.h - TransitionState::BAR_HEIGHT, w: args.grid.w, h: TransitionState::BAR_HEIGHT, r: 0, g: 0, b: 0 }.solid
    end
    # Dialogue
    @dialogue_sections.each do |pos, dialogue|
      next unless dialogue
      dialogue.draw(pos)
    end
end

  def set_dialogue(pos, dialogue)
    @dialogue_sections[pos.to_sym] = dialogue
  end

  private

  def script_path
    "scripts/#{@script}.rb"
  end
end
