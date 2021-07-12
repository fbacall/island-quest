class Player
  attr_sprite

  DIRECTION_MATRIX = [-1, 0, 1].product([-1, 0, 1])

  attr_accessor :x_pos, :y_pos, # World position
                :x_vel, :y_vel,
                :x_accel, :y_accel,
                :max_speed, :max_accel, :friction, :dir, :skipped_frames, :frame, :z_index

  attr_reader :interactables

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
    @path = 'gfx/man.png'
    @a = 255
    @r = 255
    @g = 255
    @b = 255
    @angle = 0
    @source_w = 16
    @source_h = 16
    @max_speed = 2
    @max_accel = 0.4
    @friction = 0.25
    @skipped_frames = 0
    @frame = 0
    @dir = 'down'
    @z_index = 100
    $gtk.args.audio[:footstep] ||= {
      input: 'sounds/sand.wav',  # Filename
      x: 0.0, y: 0.0, z: 0.0,    # Relative position to the listener, x, y, z from -1.0 to 1.0
      gain: 0.2,                 # Volume (0.0 to 1.0)
      pitch: 1.0,                # Pitch of the sound (1.0 = original pitch)
      paused: true,              # Set to true to pause the sound at the current playback position
      looping: true              # Set to true to loop the sound/music until you stop it
    }
  end

  def x
    # Keep player in center of screen until they approach the map edge.
    if x_pos < camera_center_x
      x_pos
    elsif x_pos > ($gtk.args.state.map.w - camera_center_x)
      camera_center_x + (x_pos - ($gtk.args.state.map.w - camera_center_x))
    else
      camera_center_x
    end * $gtk.args.state.game_scale - w.half
  end

  def y
    if y_pos < camera_center_y
      y_pos
    elsif y_pos > ($gtk.args.state.map.h - camera_center_y)
      camera_center_y + (y_pos - ($gtk.args.state.map.h - camera_center_y))
    else
      camera_center_y
    end * $gtk.args.state.game_scale - h.half
  end

  def w
    @source_w * $gtk.args.state.game_scale
  end

  def h
    @source_h * $gtk.args.state.game_scale
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

    $gtk.args.audio[:thud] ||= {
      input: 'sounds/thud.wav',
      x: 0.0, y: 0.0, z: 0.0,
      gain: 1.0,
      pitch: 1.0,
      paused: true,
      looping: false,
    }

    move
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
    next_x = (x_pos + x_vel).clamp(w.half, $gtk.args.state.map.w - w.half)
    next_y = (y_pos + y_vel).clamp(h.half, $gtk.args.state.map.h - h.half)
    orig_speed = speed

    if collision?(next_x + (x_vel > 0 ? 8 : -8), y_pos)
      self.x_vel = 0
      self.x_accel = 0
    else
      self.x_pos = next_x
    end

    if collision?(x_pos, next_y + (y_vel > 0 ? 8 : -8))
      self.y_vel = 0
      self.y_accel = 0
    else
      self.y_pos = next_y
    end

    # thud!
    if speed - orig_speed < -1.5
      $gtk.args.audio[:thud][:paused] = false
    end

    footsteps
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
    #$gtk.args.audio[:footstep][:pitch] = 0.5 + ($gtk.args.state.map.tile_at(x_pos, y_pos, 0).id.to_f / 3)
  end

  def collision?(next_x, next_y)
    next_tile1, next_tile2 = $gtk.args.state.map.tiles_at(next_x, next_y)

    !walkable_terrains.include?(next_tile1.properties[:terrain]) || next_tile2 && next_tile2.properties.collide?
  end

  def nearby_interactables
    dist = 10
    surrounding_tiles = DIRECTION_MATRIX.map do |x, y|
      $gtk.args.state.map.tile_at(x_pos + (x * dist), y_pos + (y * dist), 1)
    end

    surrounding_tiles.select { |tile| tile && (tile.type == 'Item' || tile.type == 'Interactable') }
  end

  def walkable_terrains
    t = ['sand', 'grass', 'long_grass']
  end

  def debug_info
    "Player: #{x_pos.round(1)}, #{y_pos.round(1)}
 [A: #{x_accel.round(1)}, #{y_accel.round(1)}]
 [V: #{x_vel.round(1)}, #{y_vel.round(1)}]
 (Draw: #{x}, #{y})
 (Dir: #{dir} #{source_x} #{source_y} #{frame})"
  end

  def dialogue_avatar
    {
      path: path,
      w: 32 * $gtk.args.state.avatar_scale,
      h: 20 * $gtk.args.state.avatar_scale,
      source_x: 16,
      source_y: 54,
      source_w: 16,
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

  def camera_center_x
    $gtk.args.grid.center_x / $gtk.args.state.game_scale
  end

  def camera_center_y
    $gtk.args.grid.center_y / $gtk.args.state.game_scale
  end
end
