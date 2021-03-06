class ItemEntity < TileEntity
  attr_accessor :name

  def initialize(name, tile_id: 255, x: -8192, y: -8192, z_index: 50, **other)
    super(tile_id: tile_id, x: x, y: y, z_index: z_index, **other)
    @name = name
    @collected = false
  end

  def interact
    state_manager.push_state(ScriptState.new('pickup_item', self))
    @collected = true
  end

  def interactable?
    !@collected
  end

  def draw
    super.merge!(a: @collected ? 0 : 255)
  end
end
