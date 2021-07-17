class TileEntity < Entity
  attr_accessor :x, :y, # World position
                :w, :h, # Width/height
                :z_index, :tile_id

  def initialize(tile_id, x: 0, y: 0)
    @x = x + 8
    @y = y + 8
    @w = 16
    @h = 16
    @tile_id = tile_id.to_i
  end

  def tile
    $gtk.args.state.map.map.find_tile(@tile_id)
  end

  def draw
    super.merge(
      path: tile.path,
      tile_x: tile.tile_x.to_i,
      tile_y: tile.tile_y.to_i,
      tile_w: tile.tile_w.to_i,
      tile_h: tile.tile_h.to_i,
    )
  end
end
