class ScriptContext
  def initialize(code, entity)
    @code = code
    @entity = entity
  end

  def run
    begin
      instance_eval(@code)
    rescue Exception => e
      $gtk.notify! "Script error! :("
      puts e.class.name
      puts e.message
      puts e.backtrace.join("\n")
    end
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

  def wait(ticks = 16)
    end_tick = $gtk.args.tick_count + ticks
    action(-> () {}, -> () { $gtk.args.tick_count >= end_tick })
  end

  def fade_out(ticks = 16)
    t = ticks
    action(-> () {
      set_fade(255 * (1 - (t / ticks)))
      t -= 1
    }, -> () { t < 0 })
  end

  def fade_in(ticks = 16)
    t = ticks
    action(-> () {
      set_fade(255 * (t / ticks))
      t -= 1
    }, -> () { t < 0 })
  end

  def start_dialogue(name)
    state_manager.push_state(DialogueState.new(name, 'player' => player))
    Fiber.yield
  end

  def get_entity(name)
    map.objects.detect { |o| o.name == name }
  end

  private

  def set_fade(a)
    $gtk.args.state.fade = a
  end

  def action(tick_proc, end_condition)
    until end_condition.call
      tick_proc.call
      Fiber.yield
    end
  end
end
