class PausedState < MenuState
  def init
    super
    @options = ['Resume', 'Quit']
    @title = 'Paused'
  end

  def handle_input(args)
    handle_option('Resume') if args.inputs.keyboard.key_down.escape
  end

  def handle_option(option)
    case option
    when 'Resume'
      pop_state
    when 'Quit'
      $gtk.args.gtk.request_quit
    end
  end
end
