class ScriptContext
  TIMEOUT = 600

  def initialize(code, entity, state)
    @code = code
    @entity = entity
    @state = state
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

  def state
    @state
  end

  def done!
    entity.done = true
  end

  def stop(actor)
    actor.x_accel = 0
    actor.y_accel = 0
    actor.x_vel = 0
    actor.y_vel = 0
  end

  def move(actor, x, y)
    ticks = 0
    action -> () {
      ticks += 1
      if (actor.x - x).abs < 4 && (actor.y - y).abs < 4
        actor.x_accel = 0
        actor.y_accel = 0
      else
        actor.x_accel = x - actor.x
        actor.y_accel = y - actor.y
      end

      actor.tick
    },
           -> () {
             actor.speed == 0
           }
  end

  def wait(ticks = 16)
    end_tick = $gtk.args.tick_count + ticks
    action -> () {},
           -> () { $gtk.args.tick_count >= end_tick }
  end

  def fade_out(ticks = 16)
    t = ticks
    action -> () {
      set_fade(255 * (1 - (t / ticks)))
      t -= 1
    },
           -> () { t < 0 }
  end

  def fade_in(ticks = 16)
    t = ticks
    action -> () {
      set_fade(255 * (t / ticks))
      t -= 1    },
           -> () { t < 0 }

  end

  def start_dialogue(name)
    state_manager.push_state(DialogueState.new(name, 'player' => player))
    Fiber.yield
  end

  def get_entity(name)
    map.objects.detect { |o| o.respond_to?(:name) && o.name == name }
  end

  def has_item?(name)
    player.has_item?(name)
  end

  def add_item(entity)
    player.add_item(entity)
  end

  def remove_item(name)
    player.inventory.delete_if { |i| i.name == name }
  end

  def dialogue(position, speech, entity = nil)
    d = Dialogue.new(speech, entity)
    state.set_dialogue(position, d)
    state_manager.push_state(DialogueState.new(d))
    Fiber.yield
  end

  def play_sound(sound)
    $gtk.args.audio["script_#{sound}".to_sym] ||= {
      input: "sounds/#{sound}.wav",
      x: 0.0, y: 0.0, z: 0.0,
      gain: 1.0,
      pitch: 1.0,
      paused: false,
      looping: false,
    }
  end

  private

  def set_fade(a)
    $gtk.args.state.fade = a
  end

  def action(tick_proc, end_condition)
    ttl = TIMEOUT
    loop do
      ttl -= 1
      tick_proc.call
      Fiber.yield
      if ttl <= 0
        $gtk.notify! 'Script action timeout!'
        break
      end
      break if end_condition.call
    end
  end
end
