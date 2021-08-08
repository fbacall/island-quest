require 'lib/tiled/tiled.rb'
require 'app/camera.rb'
require 'app/dialogue.rb'
require 'app/entities/entity.rb'
require 'app/entities/tile_entity.rb'
require 'app/entities/item_entity.rb'
require 'app/entities/interactable_entity.rb'
require 'app/entities/mobile_entity.rb'
require 'app/entities/plane_entity.rb'
require 'app/entities/player.rb'
require 'app/map_layer.rb'
require 'app/ocean_layer.rb'
require 'app/map.rb'
require 'app/script_context.rb'
require 'app/state_manager.rb'
require 'app/states/state.rb'
require 'app/states/menu_state.rb'
require 'app/states/dialogue_state.rb'
require 'app/states/transition_state.rb'
require 'app/states/script_state.rb'
require 'app/states/play_state.rb'
require 'app/states/paused_state.rb'
require 'app/states/intro_state.rb'

def tick(args)
  args.state.debug ||= false
  args.state.dputs_count = 0

  if args.tick_count <= 5
    args.outputs.solids << { x: 0, y: 0, w: args.grid.w, h: args.grid.h, r: 0, g: 0, b: 0, a: 255 }
    args.outputs.labels << { x: args.grid.center_x, y: args.grid.center_y + 20, text: 'Loading', size_enum: 20,
                             alignment_enum: 1, r: 255, g: 255, b: 255, a: 255 }
  else
    args.state._map ||= Map.new('maps/world.tmx')
    args.state._player ||= Player.new(map.w.half, map.h.half)
    args.state._camera ||= Camera.new(zoom: 4, target: player)
    args.state._state_manager ||= StateManager.new(IntroState.new)

    state_manager.current_state.handle_input(args)
    state_manager.current_state.update(args)
    state_manager.current_state.draw(args)
  end
end

def state_manager
  $gtk.args.state._state_manager
end

def camera
  $gtk.args.state._camera
end

def player
  $gtk.args.state._player
end

def map
  $gtk.args.state._map
end

def dputs(*str)
  $gtk.args.state.dputs_count += 1
  str = str.join(', ')
  $gtk.args.outputs.labels << [400, 300 + ($gtk.args.state.dputs_count * 30), str, -1]
end
