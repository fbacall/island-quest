class Player < Entity
  DIRECTION_MATRIX = [-1, 0, 1].product([-1, 0, 1])

  attr_accessor :prev_x, :prev_y, # Last frame position
                :prev_speed, # Last frame speed (for impulse calc)
                :x_vel, :y_vel,
                :x_accel, :y_accel,
                :max_speed, :max_accel, :friction, :dir, :skipped_frames, :frame

  attr_reader :interactables

  def initialize(x, y)
    super(x: x, y: y, w: 16, h: 16)
    @x_vel = 0
    @y_vel = 0
    @x_accel = 0
    @y_accel = 0
    @path = 'gfx/man.png'
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
    self.x = (x + x_vel).clamp(w.half, $gtk.args.state.map.w - w.half)
    self.y = (y + y_vel).clamp(h.half, $gtk.args.state.map.h - h.half)

    true
  end

  def collide
    if collision?(x, prev_y)
      self.x_vel = 0
      self.x_accel = 0
      self.x = prev_x
    end

    if collision?(prev_x, y)
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
    #$gtk.args.audio[:footstep][:pitch] = 0.5 + ($gtk.args.state.map.tile_at(x, y, 0).id.to_f / 3)
  end

  def collision?(x, y)
    next_tiles1, next_tiles2 = $gtk.args.state.map.tiles_in(
      x - w.third,
      y + h.third,
      x + w.third,
      y - h.third)

    next_tiles1.any? { |t| !walkable_terrains.include?(t.properties[:terrain]) } || next_tiles2.any? { |t| t.properties.collide? }
  end

  def nearby_interactables
    dist = 10
    surrounding_tiles = $gtk.args.state.map.tiles_in_layer(x - dist, y - dist, x + dist, y + dist, 1)

    surrounding_tiles.select { |tile| tile && (tile.type == 'Item' || tile.type == 'Interactable') }
  end

  def walkable_terrains
    t = ['sand', 'grass', 'long_grass']
  end

  def debug_info
    "Player: #{x.round(1)}, #{y.round(1)}
 [A: #{x_accel.round(1)}, #{y_accel.round(1)}]
 [V: #{x_vel.round(1)}, #{y_vel.round(1)}]
 (Pos: #{x}, #{y})
 (Anim: #{dir} #{frame})"
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
    super.merge({
                  source_x: source_x,
                  source_y: source_y,
                  source_w: 16,
                  source_h: 16,
                  path: @path
                })
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
end
