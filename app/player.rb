class Player
  attr_sprite

  attr_accessor :x_pos, :y_pos, # World position
                :x_vel, :y_vel,
                :x_accel, :y_accel,
                :max_speed, :max_accel, :friction, :dir, :skipped_frames, :frame

  def initialize(x, y)
    super
    @w = 0
    @h = 0
    @x_pos = x
    @y_pos = y
    @x_vel = 0
    @y_vel = 0
    @x_accel = 0
    @y_accel = 0
    @path = 'maps/man.png'
    @a = 255
    @r = 255
    @g = 255
    @b = 255
    @angle = 0
    @source_w = 16
    @source_h = 16
    @max_speed = 3
    @max_accel = 0.8
    @friction = 0.25
    @skipped_frames = 0
    @frame = 0
    @dir = 'down'
  end

  def x
    if x_pos < camera_center_x
      x_pos
    elsif x_pos > ($gtk.args.state.world.w - camera_center_x)
      camera_center_x + (x_pos - ($gtk.args.state.world.w - camera_center_x))
    else
      camera_center_x
    end * $gtk.args.state.game_scale
  end

  def y
    if y_pos < camera_center_y
      y_pos
    elsif y_pos > ($gtk.args.state.world.w - camera_center_y)
      camera_center_y + (y_pos - ($gtk.args.state.world.w - camera_center_y))
    else
      camera_center_y
    end * $gtk.args.state.game_scale
  end

  def w
    16 * $gtk.args.state.game_scale
  end

  def h
    16 * $gtk.args.state.game_scale
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

  def source_x
    if speed > 0.1
      @frame * 16
    else
      16
    end
  end

  def source_y
    case dir
    when 'up'
      0
    when 'down'
      16
    when 'left'
      32
    when 'right'
      48
    end
  end

  def tick
    accelerate
    apply_friction
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

  def serialize
    { x_pos: x_pos, y_pos: y_pos,
      x_vel: x_vel, y_vel: y_vel,
      x_accel: x_accel, y_accel: y_accel,
      max_speed: max_speed, max_accel: max_accel, friction: friction, dir: dir, skipped_frames: skipped_frames, frame: frame }
  end

  # 2. Override the inspect method and return ~serialize.to_s~.
  def inspect
    serialize.to_s
  end

  # 3. Override to_s and return ~serialize.to_s~.
  def to_s
    serialize.to_s
  end

  def debug_info
    "Player: #{x_pos}, #{y_pos} [A: #{x_accel}, #{y_accel}] [V: #{x_vel}, #{y_vel}] (Draw: #{x}, #{y}) (Dir: #{dir} #{source_x} #{source_y} #{frame})"
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

  def camera_center_x
    $gtk.args.grid.center_x / $gtk.args.state.game_scale
  end

  def camera_center_y
    $gtk.args.grid.center_y / $gtk.args.state.game_scale
  end
end