class TransitionState < State
  BAR_HEIGHT = 60

  def initialize(direction, duration = 16)
    @direction = direction
    @duration = duration
    @ttl = duration
  end

  def update(args)
    if @ttl > 0
      @ttl -= 1
    else
      pop_state
    end
  end

  def draw(args)
    previous_state&.draw(args)
    letterbox_height = BAR_HEIGHT * (@ttl / @duration)
    letterbox_height = BAR_HEIGHT - letterbox_height if @direction == :in
    args.outputs.primitives << { x: 0, y: 0, w: args.grid.w, h: letterbox_height, r: 0, g: 0, b: 0 }.solid
    args.outputs.primitives << { x: 0, y: args.grid.h - letterbox_height, w: args.grid.w, h: letterbox_height, r: 0, g: 0, b: 0 }.solid
  end
end
