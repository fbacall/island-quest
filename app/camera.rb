class Camera
  attr_accessor :zoom
  attr_reader :target

  def initialize(x = 0, y = 0, zoom: 1, target: nil)
    @x = x
    @y = y
    @zoom = zoom
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
    min_x = $gtk.args.grid.center_x / zoom
    target_x.clamp(min_x, (map.w - min_x))
  end

  def adjusted_y
    min_y = $gtk.args.grid.center_y / zoom
    target_y.clamp(min_y, (map.h - min_y))
  end

  def screen_coords(entity)
    {
      x: ((entity.left - adjusted_x) * zoom + $gtk.args.grid.center_x).round,
      y: ((entity.top - adjusted_y) * zoom + $gtk.args.grid.center_y).round,
      w: entity.w * zoom,
      h: entity.h * zoom
    }
  end

  def screen_coords_rect(*rect)
    w = rect[2] - rect[0]
    h = rect[3] - rect[1]
    {
      x: ((rect[0] - adjusted_x) * zoom + $gtk.args.grid.center_x).round,
      y: ((rect[1] - adjusted_y) * zoom + $gtk.args.grid.center_y).round,
      w: w * zoom,
      h: h * zoom
    }
  end

  def serialize
    { x: @x, y: @y, zoom: @zoom, target: @target&.name }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
