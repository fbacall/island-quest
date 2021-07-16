class MapLayer
  attr_sprite

  attr_accessor :z_index, :target, :target_key, :map

  def initialize(map, tiled_layer)
    @map = map
    @target_key = "layer_#{tiled_layer.attributes.id}".to_sym
    @target = $gtk.args.render_target(@target_key)
    @target.width = map.w
    @target.height = map.h
    @target.sprites << tiled_layer.sprites
    super
    @z_index = tiled_layer.properties.zindex
  end

  def x_pos
    map.w.half
  end

  def y_pos
    map.h.half
  end

  def x
    $camera.draw_x(self)
  end

  def y
    $camera.draw_y(self)
  end

  def w
    map.w * $camera.scale
  end

  def h
    map.h * $camera.scale
  end

  def path
    target_key
  end
end
