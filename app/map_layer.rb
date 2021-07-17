class MapLayer < Entity
  attr_accessor :z_index, :target, :target_key, :map

  def initialize(map, tiled_layer)
    @map = map
    @target_key = "layer_#{tiled_layer.attributes.id}".to_sym
    @target = $gtk.args.render_target(@target_key)
    @target.width = map.w
    @target.height = map.h
    @target.sprites << tiled_layer.sprites
    @z_index = tiled_layer.properties.zindex
    super(x: map.w.half, y: map.h.half, w: map.w, h: map.h)
  end

  def draw
    super.merge(path: target_key)
  end
end
