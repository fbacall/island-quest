class DialogueState < State
  def initialize(dialogue)
    @dialogue = dialogue
  end

  def handle_input(args)
    speed = 3
    if args.inputs.keyboard.key_held.shift
      speed = 1
      delay = 0
      @dialogue.delay = delay
    end
    @dialogue.speed = speed
    if @paused && (args.inputs.keyboard.key_down.space || args.inputs.keyboard.key_down.enter)
      @dialogue.active = false
      pop_state
    end
  end

  def update(args)
    return if @paused

    @dialogue.tick
    pause if @dialogue.done?
  end

  def draw(args)
    previous_state&.draw(args)
  end
end
