class TileEntity < Entity
  INVENTORY_SCALE = 4
  attr_accessor :tile_id

  def initialize(tile_id: 255, x: 0, y: 0, z_index: 50, **other)
    @x = x
    @y = y
    @w = 16
    @h = 16
    @z_index = z_index
    @tile_id = tile_id.to_i
  end

  def collide?
    tile.properties.collide?
  end

  def tile
    map.map.find_tile(@tile_id)
  end

  def draw
    super.merge!(
      path: tile.path,
      tile_x: tile.tile_x.to_i,
      tile_y: tile.tile_y.to_i,
      tile_w: tile.tile_w.to_i,
      tile_h: tile.tile_h.to_i
    )
  end

  def inventory_draw(slot)
    draw.merge!(w: w * INVENTORY_SCALE,
                h: h * INVENTORY_SCALE,
                x: $gtk.args.grid.w - 20 * INVENTORY_SCALE,
                y: $gtk.args.grid.h - ((20 + slot * 20) * INVENTORY_SCALE),
                a: 255)
  end
end
