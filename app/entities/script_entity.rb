class ScriptEntity < TileEntity
  attr_accessor :name, :done

  def initialize(name, tile_id, x: 0, y: 0, z_index: 50)
    super(tile_id, x: x, y: y, z_index: z_index)
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
