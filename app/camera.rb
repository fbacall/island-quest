class Camera
  attr_accessor :scale
  attr_reader :target

  def initialize(x, y)
    @x = x
    @y = y
    @scale = 1
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
    if target_x < center_x
      center_x
    elsif target_x > ($gtk.args.state.map.w - center_x)
      ($gtk.args.state.map.w - center_x)
    else
      target_x
    end
  end

  def adjusted_y
    if target_y < center_y
      center_y
    elsif target_y > ($gtk.args.state.map.h - center_y)
      ($gtk.args.state.map.h - center_y)
    else
      target_y
    end
  end

  def center_x
    $gtk.args.grid.center_x / scale
  end

  def center_y
    $gtk.args.grid.center_y / scale
  end

  def screen_coords(entity)
    {
      x: (entity.left_edge - adjusted_x) * scale + $gtk.args.grid.center_x,
      y: (entity.top_edge - adjusted_y) * scale + $gtk.args.grid.center_y,
      w: entity.w * scale,
      h: entity.h * scale
    }
  end
end