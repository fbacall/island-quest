class Map
  attr_accessor :map, :attributes, :w, :h, :tile_h, :tile_w, :w_tiles, :h_tiles

  def initialize(path)
    @map = Tiled::Map.new(path)
    map.load
    @attributes = map.attributes
    @tile_w = map.attributes.tilewidth.to_i
    @tile_h = map.attributes.tileheight.to_i
    @w_tiles = map.attributes.width.to_i
    @h_tiles = map.attributes.height.to_i
    @w = @tile_w * @w_tiles
    @h = @tile_h * @h_tiles
    @layers = map.layers.map { |layer| MapLayer.new(self, layer) }
    @layers += map.object_groups.map { |oj| MapLayer.new(self, oj) }
  end

  def layers
    @layers
  end

  def tiles_at(x, y)
    map.layers.count.times.map { |layer| tile_at(x, y, layer) }
  end

  def tile_at(x, y, layer)
    map.layers.at(layer).tile_at(*tile_coords(x, y))
  end

  def tiles_in_layer(x1, y1, x2, y2, layer)
    tile_coords_in(x1, y1, x2, y2).map do |x, y|
      map.layers.at(layer).tile_at(x, y)
    end
  end

  def tiles_in(x1, y1, x2, y2)
    map.layers.count.times.map { |layer| tiles_in_layer(x1, y1, x2, y2, layer) }
  end

  def tile_coords(x, y)
    [(x / tile_w).round, (h_tiles - 1) - (y / tile_h).round]
  end

  def tile_coords_in(x1, y1, x2, y2)
    if y1 < y2
      top = y1
      bottom = y2
    else
      top = y2
      bottom = y1
    end
    if x1 < x2
      left = x1
      right = x2
    else
      left = x2
      right = x1
    end

    tx1, ty1 = tile_coords(left, top)
    tx2, ty2 = tile_coords(right, bottom)


    (tx1..tx2).to_a.product((ty2..ty1).to_a)
  end
end
