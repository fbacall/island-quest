class StateManager
  def initialize(initial_state)
    @states = []
    push_state(initial_state)
  end

  def current_state
    @states.last
  end

  def previous_state
    @states[-2]
  end

  def push_state(state)
    prev = current_state
    prev.pause if prev
    @states.push(state)
    current_state.init
  end

  def pop_state
    @states.pop
    current_state.resume if current_state
  end

  def set_state(state)
    @states.pop
    @states.push(state)
    current_state.init
  end
end