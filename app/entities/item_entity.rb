class ItemEntity < TileEntity
  attr_accessor :name

  def initialize(name, tile_id, x: 0, y: 0, z_index: 50)
    super(tile_id, x: x, y: y, z_index: z_index)
    @name = name
    @collected = false
  end

  def interact
    player.inventory << self unless player.inventory.include?(self)
    state_manager.push_state(DialogueState.new('item', {}, { item: name }))
    @collected = true
  end

  def interactable?
    !@collected
  end

  def draw
    super.merge!(a: @collected ? 0 : 255)
  end
end
