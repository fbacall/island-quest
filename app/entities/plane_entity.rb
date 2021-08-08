class PlaneEntity < MobileEntity
  attr_accessor :empty, :revs

  def initialize(name, x: 0, y: 0, w: 64, h: 48, **other)
    super(name, sprite: 'biplane', x: x, y: y, w: w, h: h, **other)
    @empty = true
    @visible = true
    @unbounded = true
    @revs = 0
    @max_accel = 0.27
    @z_index = 90
    @frames_per_anim = 3
    @lock_dir = true
  end

  def frameskip
    (10 - Math.sqrt(revs)) * 2
  end

  def max_speed
    1.5 * (revs.to_f / 100)
  end

  def footsteps
    $gtk.args.audio[:plane_engine] ||= { input: 'sounds/plane.wav',
                                         x: 0.0, y: 0.0, z: 0.0,
                                         gain: 0.5, pitch: 1.0, paused: false, looping: true }
    if revs > 4
      $gtk.args.audio[:plane_engine][:looping] = true
    elsif revs < 1
      $gtk.args.audio[:plane_engine][:looping] = false
    end

    $gtk.args.audio[:plane_engine][:pitch] = 0.5 + (revs.to_f / 100)
  end

  def draw
    source_x = revs > 0 ? @frame * 64 : 0

    if @empty
      source_y = 0
    elsif revs < 85
      source_y = 48
    else
      source_y = 96
    end

    super.merge!({ source_x: source_x, source_y: source_y })
  end
end
