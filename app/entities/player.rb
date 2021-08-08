class Player < MobileEntity
  attr_accessor :inventory

  attr_reader :interactable, :walkable_terrains

  def initialize(x, y)
    super('player', sprite: 'man', x: x, y: y, w: 16, h: 16)
    @visible = true
    @noclip = false
    @inventory = []
    @walkable_terrains = ['sand', 'grass', 'long_grass']
    $gtk.args.audio[:swim] ||= {
      input: 'sounds/swim.wav',
      x: 0.0, y: 0.0, z: 0.0,
      gain: 0.1,
      pitch: 1.0,
      paused: true,
      looping: true
    }
  end

  def tick
    super
    @interactable = nearby_interactable
    @current_terrain = get_current_terrain
  end

  def collision?(x, y)
    terrain_tiles = map.tiles_in_layer(x - w.third, y + h.third,
                                       x + w.third, y - h.third, 0)

    $gtk.args.outputs.primitives << camera.screen_coords_rect(x - w.third, y + h.third,
                                                              x + w.third, y - h.third).merge!(r: 255, g: 0, b: 0, a: 128).solid if $gtk.args.state.debug

    super || terrain_tiles.any? { |t| !walkable_terrains.include?(t.properties[:terrain]) }
  end

  def nearby_interactable
    map.objects.detect do |obj|
      obj.interactable? && obj.intersect_rect?(self)
    end
  end

  def get_current_terrain
    map.tile_at(x, y, 0)&.properties[:terrain]
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

  def draw
    h = super

    if @current_terrain == 'water'
      h.merge!({
                 source_y: h[:source_y] + 3,
                 source_h: h[:source_h] - 3,
                 h: h[:h] - 3 * camera.zoom
               })
    elsif @current_terrain == 'deep_water'
      h.merge!({
                 source_y: h[:source_y] + 6,
                 source_h: h[:source_h] - 6,
                 h: h[:h] - 6 * camera.zoom
               })
    else
      h
    end
  end

  def footsteps
    if @current_terrain == 'water' || @current_terrain == 'deep_water'
      $gtk.args.audio[:footstep][:paused] = true
      s = speed
      m = max_speed
      # "Debounce" the pausing of footstep sound to avoid rapid pausing causing horrible static sound + HTML5 crash
      if s > m.half
        $gtk.args.audio[:swim][:paused] = false
      elsif s < m * 0.1
        $gtk.args.audio[:swim][:paused] = true
      end
      $gtk.args.audio[:swim][:pitch] = @current_terrain == 'deep_water' ? 0.7 : 1.0
    else
      $gtk.args.audio[:swim][:paused] = true
      super
    end
  end
end
