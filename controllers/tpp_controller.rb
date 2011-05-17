# Implements a generic controller from which all other controllers need to be derived.
class TppController
  [:initialize, :close, :run].each do |method|
    define_method method do
      $stderr.puts "Error: TppController.#{method} has been called directly!"
      Kernel.exit(1)
    end
  end

  class << self
    def build_controller(cli_parser)
      case cli_parser.type
      when "ncurses"
        InteractiveController.new(cli_parser.input, NcursesVisualizer)
      when "autoplay"
        AutoplayController.new(cli_parser.input, cli_parser.time, NcursesVisualizer)
      when "txt"
        ConversionController.new(cli_parser.input, cli_parser.output, TextVisualizer) if cli_parser.output
      when "latex"
        ConversionController.new(cli_parser.input, cli_parser.output, LatexVisualizer) if cli_parser.output
      else
        nil
      end
    end
  end`
end

