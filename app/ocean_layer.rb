class OceanLayer < Entity
  attr_accessor :target, :target_key, :map, :size, :gap, :offset

  def initialize(map, size, gap, offset)
    @map = map
    @size = size
    @gap = gap
    @offset = offset
    @target_key = "ocean_layer_#{size}_#{gap}_#{offset}".to_sym
    @target = $gtk.args.render_target(@target_key)
    @target.width = map.w
    @target.height = map.h
    y = @offset
    while y <= map.h do
      @target.solids << { x: 0, y: y, w: map.w, h: size, r: 99, g: 194, b: 201 }
      y += size + gap
    end
    super(x: map.w.half, y: map.h.half, w: map.w, h: map.h)
    @z_index = -100
  end

  def draw
    s = 128
    phase = Math.sin(offset * (Math::PI / 4) + $gtk.args.tick_count / 24) * s
    super.merge!(path: target_key, a: (255 - s + phase))
  end
end
