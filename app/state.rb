class State
  attr_accessor :previous_state

  def init
    @paused = false
  end

  def pause
    @paused = true
  end

  def resume
    @paused = false
  end

  def handle_input(args)
  end

  def update(args)
  end

  def draw(args)
  end

  def push_state(state)
    $state_manager.push_state(state)
  end

  def pop_state
    $state_manager.pop_state
  end

  def set_state(state)
    $state_manager.set_state(state)
  end
end
