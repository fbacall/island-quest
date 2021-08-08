class Player < MobileEntity
  attr_accessor :inventory

  attr_reader :interactable, :walkable_terrains

  def initialize(x, y)
    super('player', sprite: 'man', x: x, y: y, w: 16, h: 16)
    @visible = true
    @noclip = false
    @inventory = []
    @walkable_terrains = ['sand', 'grass', 'long_grass']
  end

  def tick
    super
    @interactable = nearby_interactable
    @current_terrain = get_current_terrain
  end

  def collision?(target_x, target_y)
    terrain_tiles = map.tiles_in_layer(target_x - w.third, target_y + h.third,
                                       target_x + w.third, target_y - h.third, 0)
    if $gtk.args.state.debug
      $gtk.args.outputs.primitives << camera.screen_coords_rect(
        target_x - w.third, target_y + h.third,
        target_x + w.third, target_y - h.third).merge!(r: 255, g: 0, b: 0, a: 128).solid
    end

    super || terrain_tiles.any? { |t| !walkable_terrains.include?(t.properties[:terrain]) }
  end

  def nearby_interactable
    map.objects.detect do |obj|
      obj.interactable? && obj.intersect_rect?(self)
    end
  end

  def get_current_terrain
    map.tile_at(x, y, 0)&.properties&.[](:terrain)
  end

  def has_item?(name)
    inventory.any? { |i| i.name == name }
  end

  def add_item(entity)
    inventory << entity unless has_item?(entity.name)
    walkable_terrains << 'water' if entity.name == 'flippers'
    walkable_terrains << 'deep_water' if entity.name == 'snorkel'
    inventory
  end

  def debug_info
    "Player: #{x.round(1)}, #{y.round(1)}
 [A: #{x_accel.round(1)}, #{y_accel.round(1)}]
 [V: #{x_vel.round(1)}, #{y_vel.round(1)}]
 (Pos: #{x}, #{y})
 (Anim: #{dir} #{frame})"
  end

  def max_speed
    if @current_terrain == 'water'
      super * 0.8
    elsif @current_terrain == 'deep_water'
      super * 0.6
    else
      super
    end
  end
end
