module Util
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
