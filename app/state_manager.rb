class StateManager
  def initialize(initial_state)
    @states = []
    push_state(initial_state)
  end

  def current_state
    @states.last
  end

  def push_state(state)
    prev = current_state
    prev.pause if prev
    @states.push(state)
    current_state.init(prev)
  end

  def pop_state
    @states.pop
    current_state.resume if current_state
  end

  def set_state(state)
    prev = @states.pop
    @states.push(state)
    current_state.init(prev)
  end
end