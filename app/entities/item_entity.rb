class ItemEntity < TileEntity
  attr_accessor :name

  def initialize(name, tile_id, x: 0, y: 0, z_index: 50)
    super(tile_id, x: x, y: y, z_index: z_index)
    @name = name
    @collected = false
  end

  def interact
    $gtk.args.state.player.inventory << self unless $gtk.args.state.player.inventory.include?(self)
    $state_manager.push_state(DialogueState.new('item', {}, { item: name }))
    @collected = true
  end

  def interactable?
    !@collected
  end

  def draw
    super unless @collected
  end

  def inventory_draw(i)
    {}#tile_draw.merge(x: args.grid.w - 32 * $camera.scale, y: (32 + i * 24) * $camera.scale)
  end
end
