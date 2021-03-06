class InteractableEntity < TileEntity
  attr_accessor :name, :done

  def initialize(name, tile_id: 255, x: 0, y: 0, z_index: 50, **other)
    super(tile_id: tile_id, x: x, y: y, z_index: z_index, **other)
    @name = name
    @done = false
  end

  def interact
    state_manager.push_state(ScriptState.new(name, self))
  end

  def interactable?
    !@done
  end
end
