class Entity
  include GTK::Geometry

  attr_accessor :x, :y, # World position
                :w, :h, # Width/height
                :z_index

  def initialize(x: 0, y: 0, w: 0, h: 0)
    @x = x
    @y = y
    @w = w
    @h = h
  end

  def draw
    camera.screen_coords(self)
  end

  def top
    y - h.half
  end

  def bottom
    y + h.half
  end

  def left
    x - w.half
  end

  def right
    x + w.half
  end

  def x1
    x
  end

  def y1
    y
  end
end
