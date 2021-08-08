class PlaneEntity < MobileEntity
  attr_accessor :state, :revs

  def initialize(name, x: 0, y: 0, w: 64, h: 48, **)
    super(name, sprite: 'biplane', x: x, y: y, w: w, h: h)
    @state = 'empty'
    @visible = true
    @unbounded = true
    @revs = 0
    @max_accel = 99
    @z_index = 90
    $gtk.args.audio[:plane_engine] ||= {
      input: 'sounds/plane.wav',  # Filename
      x: 0.0, y: 0.0, z: 0.0,    # Relative position to the listener, x, y, z from -1.0 to 1.0
      gain: 0.5,                 # Volume (0.0 to 1.0)
      pitch: 1.0,                # Pitch of the sound (1.0 = original pitch)
      paused: true,              # Set to true to pause the sound at the current playback position
      looping: true              # Set to true to loop the sound/music until you stop it
    }
  end

  def animate
    if (self.skipped_frames += 1) >= frameskip
      self.frame = (frame + 1) % 3
      self.skipped_frames = 0
    end
  end

  def frameskip
    (10 - Math.sqrt(revs)) * 2
  end

  def max_speed
    1.5 * (revs.to_f / 100)
  end

  def footsteps
    $gtk.args.audio[:plane_engine][:paused] = revs <= 5

    $gtk.args.audio[:plane_engine][:pitch] = 0.5 + (revs.to_f / 100)
  end

  def draw
    source_x =
      if revs > 0
        @frame * 64
      else
        0
      end

    if @state == 'empty'
      source_y = 0
    elsif revs < 85
      source_y = 48
    else
      source_y = 96
    end

    super.merge!({
                  source_x: source_x,
                  source_y: source_y,
                  source_w: 64,
                  source_h: 48,
                  path: @path,
                  a: @visible ? 255: 0
                })
  end
end
