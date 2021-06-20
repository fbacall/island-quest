class Layer
  attr_sprite

  attr_accessor :z_index, :target, :target_key, :map

  def initialize(map, tiled_layer, z_index)
    @map = map
    @target_key = "layer_#{tiled_layer.attributes.id}".to_sym
    @target = $gtk.args.render_target(@target_key)
    @target.width = map.w
    @target.height = map.h
    @target.sprites << tiled_layer.sprites
    super
    @z_index = z_index
  end

  def x
    (($gtk.args.state.player.x / $gtk.args.state.game_scale) - $gtk.args.state.player.x_pos) * $gtk.args.state.game_scale
  end

  def y
    (($gtk.args.state.player.y / $gtk.args.state.game_scale) - $gtk.args.state.player.y_pos) * $gtk.args.state.game_scale
  end

  def w
    map.w * $gtk.args.state.game_scale
  end

  def h
    map.h * $gtk.args.state.game_scale
  end

  def path
    target_key
  end
end