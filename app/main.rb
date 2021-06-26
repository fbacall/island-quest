require 'lib/tiled/tiled.rb'
require 'app/player.rb'
require 'app/map_layer.rb'
require 'app/map.rb'
require 'app/state_manager.rb'
require 'app/play_state.rb'
require 'app/paused_state.rb'

def tick(args)
  $state_manager ||= StateManager.new(PlayState.new)
  state = $state_manager.current_state

  state.handle_input(args)
  state.update(args)
  state.draw(args)
end
