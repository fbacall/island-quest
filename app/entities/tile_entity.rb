class TileEntity < Entity
  attr_accessor :tile_id

  def initialize(tile_id, x: 0, y: 0, z_index: 50)
    @x = x
    @y = y
    @w = 16
    @h = 16
    @z_index = z_index
    @tile_id = tile_id.to_i
  end

  def interactable?
    false
  end

  def collide?
    tile.properties.collide?
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
      tile_h: tile.tile_h.to_i
    )
  end
end
