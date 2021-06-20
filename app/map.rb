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
    @layers = map.layers.map.with_index { |layer, index| Layer.new(self, layer, index * 100) }
  end

  def layers
    @layers
  end

  def tiles_at(x, y)
    map.layers.map { |layer| layer.tile_at(*tile_coords(x, y)) }
  end

  def tile_at(x, y, layer)
    map.layers.at(layer).tile_at(*tile_coords(x, y))
  end

  def tile_coords(x, y)
    [(x / tile_w).round, (h_tiles - 1) - (y / tile_h).round]
  end
end