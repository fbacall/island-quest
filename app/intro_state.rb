class IntroState < MenuState
  def init
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
end
