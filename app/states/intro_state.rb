class IntroState < MenuState
  def init
    $gtk.args.state.fade = 0
    super
    @options = ['Start', 'Quit']
    @title = 'Island Quest'
  end

  def handle_option(option)
    case option
    when 'Start'
      set_state(PlayState.new)
    when 'Quit'
      $gtk.args.gtk.request_quit
    end
  end

  def draw(args)
    args.outputs.sprites << {
      path: 'gfx/splash_screen.png',
      w: args.grid.w,
      h: args.grid.h,
      x:0,
      y: 0
    }

    super
  end
end
