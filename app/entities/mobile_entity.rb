class MobileEntity < Entity
  DIRECTION_MATRIX = [-1, 0, 1].product([-1, 0, 1])

  attr_accessor :prev_x, :prev_y, # Last frame position
                :prev_speed, # Last frame speed (for impulse calc)
                :x_vel, :y_vel,
                :x_accel, :y_accel,
                :max_speed, :max_accel, :friction, :dir, :skipped_frames, :frame, :visible

  attr_reader :interactables

  def initialize(x: 0, y: 0, w: 16, h: 16)
    super(x: x, y: y, w: w, h: h)
    @x_vel = 0
    @y_vel = 0
    @x_accel = 0
    @y_accel = 0
    @friction = 0.25
    @skipped_frames = 0
    @frame = 0
    @dir = 'down'
    @z_index = 100
    @visible = true
    $gtk.args.audio[:footstep] ||= {
      input: 'sounds/sand.wav',  # Filename
      x: 0.0, y: 0.0, z: 0.0,    # Relative position to the listener, x, y, z from -1.0 to 1.0
      gain: 0.1,                 # Volume (0.0 to 1.0)
      pitch: 1.0,                # Pitch of the sound (1.0 = original pitch)
      paused: true,              # Set to true to pause the sound at the current playback position
      looping: true              # Set to true to loop the sound/music until you stop it
    }
  end

  def speed
    mag(x_vel, y_vel)
  end

  def accel
    mag(x_accel, y_accel)
  end

  def frameskip
    (max_speed * 1.5 - speed) * 3
  end

  def tick
    @prev_x = x
    @prev_y = y
    @prev_speed = speed
    accelerate
    apply_friction
    animate
    if speed > 0
      move
      collide
    end
    footsteps
    @interactables = nearby_interactables
  end

  def accelerate
    self.x_accel, self.y_accel = normalise(x_accel, y_accel, max_accel)
    self.x_vel += x_accel
    self.y_vel += y_accel
    if speed > max_speed
      self.x_vel, self.y_vel = normalise(x_vel, y_vel, max_speed)
    end
  end

  def apply_friction
    fric_x, fric_y = normalise(x_vel, y_vel, friction)
    if fric_x.abs < x_vel.abs
      self.x_vel -= fric_x
    else
      self.x_vel = 0
    end
    if fric_y.abs < y_vel.abs
      self.y_vel -= fric_y
    else
      self.y_vel = 0
    end
  end

  def move
    self.x = (x + x_vel).clamp(w.half, map.w - w.half)
    self.y = (y + y_vel).clamp(h.half, map.h - h.half)

    true
  end

  def collide
    return if noclip
    x_col = collision?(x, prev_y)
    y_col = collision?(prev_x, y)

    if x_col
      dputs 'X Col' if $gtk.args.state.debug
      self.x_vel = 0
      self.x_accel = 0
      self.x = prev_x
    end

    if y_col
      dputs 'Y Col' if $gtk.args.state.debug
      self.y_vel = 0
      self.y_accel = 0
      self.y = prev_y
    end

    # thud!
    if speed - @prev_speed < -1.5
      $gtk.args.audio[:thud] ||= {
        input: 'sounds/thud.wav',
        x: 0.0, y: 0.0, z: 0.0,
        gain: 1.0,
        pitch: 1.0,
        paused: false,
        looping: false,
      }
    end
  end

  def animate
    unless x_accel == 0 && y_accel == 0
      if x_accel.abs > y_accel.abs
        if x_accel > 0
          self.dir = 'right'
        else
          self.dir = 'left'
        end
      else
        if y_accel > 0
          self.dir = 'up'
        else
          self.dir = 'down'
        end
      end
    end

    if (self.skipped_frames += 1) >= frameskip
      self.frame = (frame + 1) % 4
      self.skipped_frames = 0
    end
  end

  def footsteps
    s = speed
    m = max_speed
    # "Debounce" the pausing of footstep sound to avoid rapid pausing causing horrible static sound + HTML5 crash
    if s > m.half
      $gtk.args.audio[:footstep][:paused] = false
    elsif s < m * 0.1
      $gtk.args.audio[:footstep][:paused] = true
    end

    # Shift pitch based on tile, sand is higher pitch than long grass.
    $gtk.args.audio[:footstep][:pitch] = 0.7 + @frame.to_f / 5
  end

  def collision?(x, y)
    lower_tiles = map.tiles_in_layer(x - w.third, y + h.third,
                                     x + w.third, y - h.third, 1)

    lower_tiles.any? { |t| t.properties.collide? } ||
      map.objects.any? { |obj| obj.collide? && self.intersect_rect?(obj, 1.5) }
  end

  def draw
    source_x =
      if speed > 0.1
        @frame * 16
      else
        16
      end

    source_y = case dir
               when 'up'
                 0
               when 'down'
                 16
               when 'left'
                 32
               when 'right'
                 48
               end
    super.merge!({
                  source_x: source_x,
                  source_y: source_y,
                  source_w: 16,
                  source_h: 16,
                  path: @path,
                  a: @visible ? 255: 0
                })
  end

  def dialogue_avatar
    avatar_scale = 20
    {
      path: @path,
      w: 10 * avatar_scale,
      h: 10 * avatar_scale,
      source_x: 19,
      source_y: 54,
      source_w: 10,
      source_h: 10,
    }
  end

  private

  def mag(x, y)
    Math.sqrt((x ** 2).abs + (y ** 2).abs)
  end

  def normalise(x, y, factor = 1)
    m = mag(x, y)
    return [0, 0] if m == 0
    [x * factor / m, y * factor / m]
  end
end
