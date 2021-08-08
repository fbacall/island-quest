class MobileEntity < Entity
  attr_accessor :prev_x, :prev_y, # Last frame position
                :prev_speed, # Last frame speed (for impulse calc)
                :x_vel, :y_vel,
                :x_accel, :y_accel,
                :max_speed, :max_accel,
                :friction, :dir,
                :skipped_frames, :frame,
                :visible, :path,
                :noclip, :voice_pitch

  attr_reader :name

  def initialize(name, sprite: '', x: 0, y: 0, w: 16, h: 16, **other)
    @name = name
    super(x: x, y: y, w: w, h: h, **other)
    @path = "gfx/#{sprite}.png"
    @x_vel = 0
    @y_vel = 0
    @x_accel = 0
    @y_accel = 0
    @max_speed = 2
    @max_accel = 0.4
    @friction = 0.25
    @skipped_frames = 0
    @frame = 0
    @lock_dir = false
    @dir = 'down'
    @current_terrain = nil
    @frames_per_anim = 4
    @z_index = 100
    @visible = false
    @noclip = true
    @unbounded = false
    @voice_pitch = 1.0
  end

  def speed
    mag(x_vel, y_vel)
  end

  def accel
    mag(x_accel, y_accel)
  end

  def frameskip
    (3 - speed) * 3
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
    self.x = (x + x_vel)
    self.y = (y + y_vel)
    unless @unbounded
      self.x = x.clamp(w.half, map.w - w.half)
      self.y = y.clamp(h.half, map.h - h.half)
    end

    true
  end

  def collide
    return unless collide?
    x_col = collision?(x, prev_y)
    y_col = collision?(prev_x, y)
    x_col = y_col = true if !x_col && !y_col && collision?(x, y) # Case where corner pixel collides with another corner pixel

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
      $gtk.args.audio[:thud] ||= { input: 'sounds/thud.wav',
                                   x: 0.0, y: 0.0, z: 0.0,
                                   gain: 1.0, pitch: 1.0,  paused: false, looping: false }
    end
  end

  def animate
    unless @lock_dir || (x_accel == 0 && y_accel == 0)
      face(x_accel, y_accel)
    end

    if (self.skipped_frames += 1) >= frameskip
      self.frame = (frame + 1) % @frames_per_anim
      self.skipped_frames = 0
    end
  end

  def face(relative_x, relative_y)
    if relative_x.abs > relative_y.abs
      if relative_x > 0
        self.dir = 'right'
      else
        self.dir = 'left'
      end
    else
      if relative_y > 0
        self.dir = 'up'
      else
        self.dir = 'down'
      end
    end
  end

  def collide?
    !@noclip
  end

  def footsteps
    s = speed
    m = max_speed
    # "Debounce" the pausing of footstep sound to avoid rapid pausing causing horrible static sound + HTML5 crash
    if s > m.half
      if @current_terrain == 'water' || @current_terrain == 'deep_water'
        $gtk.args.audio[:footstep][:looping] = false if $gtk.args.audio[:footstep]
        $gtk.args.audio[:swim] ||= { input: 'sounds/swim.wav',
                                     x: 0.0, y: 0.0, z: 0.0,
                                     gain: 0.1, pitch: 1.0, paused: false, looping: true }
        $gtk.args.audio[:swim][:pitch] = @current_terrain == 'deep_water' ? 0.7 : 1.0
      else
        $gtk.args.audio[:swim][:looping] = false if $gtk.args.audio[:swim]
        $gtk.args.audio[:footstep] ||= { input: 'sounds/sand.wav',
                                         x: 0.0, y: 0.0, z: 0.0,
                                         gain: 0.1, pitch: 1.0, paused: false, looping: true }
      end
    elsif s < m * 0.1
      $gtk.args.audio[:swim][:looping] = false if $gtk.args.audio[:swim]
      $gtk.args.audio[:footstep][:looping] = false if $gtk.args.audio[:footstep]
    end
  end

  def collision?(target_x, target_y)
    lower_tiles = map.tiles_in_layer(target_x - w.third, target_y + h.third,
                                     target_x + w.third, target_y - h.third, 1)

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

    hash = super.merge!({
                       source_x: source_x,
                       source_y: source_y,
                       source_w: w,
                       source_h: h,
                       path: @path,
                       a: @visible ? 255: 0
                     })

    if @current_terrain == 'water'
      hash.merge!({ source_y: source_y + 3, source_h: h - 3, h: (h - 3) * camera.zoom })
    elsif @current_terrain == 'deep_water'
      hash.merge!({ source_y: source_y + 6, source_h: h - 6, h: (h - 6) * camera.zoom })
    else
      hash
    end
  end

  def dialogue_avatar
    avatar_scale = 20
    {
      path: @path,
      w: 10 * avatar_scale,
      h: 10 * avatar_scale,
      source_x: 18,
      source_y: 52,
      source_w: 12,
      source_h: 12,
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
