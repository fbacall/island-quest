class ScriptEntity < TileEntity
  attr_accessor :script, :done

  def initialize(script, tile_id, x: 0, y: 0, z_index: 50)
    super(tile_id, x: x, y: y, z_index: z_index)
    @script = script
    @done = false
  end

  def interact
    $state_manager.push_state(ScriptState.new(script, self))
  end

  def interactable?
    !@done
  end
end
