class ScriptContext
  TIMEOUT = 600

  def initialize(code, entity, state)
    @code = code
    @entity = entity
    @state = state
    @async = false
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
    action(
      -> () {
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
    )
  end

  def face(actor, target, ticks = 16)
    t = ticks
    action(
      -> () {
        x_diff = target.x - actor.x
        y_diff = target.y - actor.y
        actor.face(x_diff, y_diff)
        t -= 1
      },
      -> () { t < 0 }
    )
  end

  def tick(actor, ticks = 16)
    t = ticks
    action(
      -> () { actor.tick; t -= 1 },
      -> () { t < 0 }
    )
  end

  def wait(ticks = 16)
    t = ticks
    action(
      -> () { t -= 1 },
      -> () { t < 0 }
    )
  end

  def fade_out(ticks = 16)
    t = ticks
    action(
      -> () {
        set_fade(255 * (1 - (t / ticks)))
        t -= 1
      },
      -> () { t < 0 }
    )
  end

  def fade_in(ticks = 16)
    t = ticks
    action(
      -> () {
        set_fade(255 * (t / ticks))
        t -= 1
      },
      -> () { t < 0 }
    )
  end

  def zoom_to(target_zoom, ticks = 16)
    current_zoom = camera.zoom
    t = ticks
    inc = (target_zoom - current_zoom).to_f / ticks
    action(
      -> () {
        camera.zoom = camera.zoom + inc
        t -= 1
      },
      -> () { t < 0 }
    )
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

  def clear_dialogue(pos = [:top, :middle, :bottom])
    Array(pos).each do |p|
      state.set_dialogue(p, nil)
    end
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

  def async(&block)
    @async = true
    @async_queue = []
    block.call
    alive_count = @async_queue.length
    while alive_count > 0
      alive_count = 0
      @async_queue.each do |f|
        if f.alive?
          f.resume
          alive_count += 1
        end
      end
      Fiber.yield
    end
  ensure
    @async = false
    @async_queue = []
  end

  private

  def set_fade(a)
    $gtk.args.state.fade = a
  end

  def action(tick_proc, end_condition)
    if @async
      @async_queue << Fiber.new do
        action_inner(tick_proc, end_condition)
      end
    else
      action_inner(tick_proc, end_condition)
    end
  end

  def action_inner(tick_proc, end_condition)
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
