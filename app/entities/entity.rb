class Entity
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
    $camera.screen_coords(self)
  end

  def top_edge
    y - h.half
  end

  def bottom_edge
    y + h.half
  end

  def left_edge
    x - w.half
  end

  def right_edge
    x + w.half
  end
end
