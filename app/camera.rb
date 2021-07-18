class Camera
  attr_accessor :scale
  attr_reader :target

  def initialize(x = 0, y = 0, scale: 1, target: nil)
    @x = x
    @y = y
    @scale = scale
    @target = target
  end

  def track(target)
    @target = target
  end

  def target_x
    @target ? @target.x : @x
  end

  def target_y
    @target ? @target.y : @y
  end

  def adjusted_x
    min_x = $gtk.args.grid.center_x / scale
    target_x.clamp(min_x, (map.w - min_x))
  end

  def adjusted_y
    min_y = $gtk.args.grid.center_y / scale
    target_y.clamp(min_y, (map.h - min_y))
  end

  def screen_coords(entity)
    {
      x: ((entity.left - adjusted_x) * scale + $gtk.args.grid.center_x).round,
      y: ((entity.top - adjusted_y) * scale + $gtk.args.grid.center_y).round,
      w: entity.w * scale,
      h: entity.h * scale
    }
  end
end
