class ScriptContext
  def initialize(code, entity)
    @code = code
    @entity = entity
  end

  def run
    instance_eval(@code)
  end

  def entity
    @entity
  end

  def done!
    @entity.done = true
  end

  def move(actor, x, y)
    action(
      -> () {
        actor.x <= x ? actor.x_accel = 1 : actor.x_accel = -1
        actor.y <= y ? actor.y_accel = 1 : actor.y_accel = -1
        actor.tick
      },
      -> () {
        (actor.x - x).abs < 5 && (actor.y - y).abs < 5
      })
  end

  def wait(ticks)
    end_tick = $gtk.args.tick_count + ticks
    action(-> () {}, -> () { $gtk.args.tick_count >= end_tick })
  end

  def start_dialogue(name)
    state_manager.push_state(DialogueState.new(name, 'player' => player))
    Fiber.yield
  end

  private

  def action(tick_proc, end_condition)
    until end_condition.call
      tick_proc.call
      Fiber.yield
    end
  end
end
