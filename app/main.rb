require 'lib/tiled/tiled.rb'
require 'app/camera.rb'
require 'app/entities/player.rb'
require 'app/map_layer.rb'
require 'app/map.rb'
require 'app/states/state_manager.rb'
require 'app/states/state.rb'
require 'app/states/menu_state.rb'
require 'app/states/dialogue_state.rb'
require 'app/script_context.rb'
require 'app/states/script_state.rb'
require 'app/states/play_state.rb'
require 'app/states/paused_state.rb'
require 'app/states/intro_state.rb'

def tick(args)
  $state_manager ||= StateManager.new(IntroState.new)

  $state_manager.current_state.handle_input(args)
  $state_manager.current_state.update(args)
  $state_manager.current_state.draw(args)
end
