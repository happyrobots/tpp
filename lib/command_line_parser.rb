class CommandLineParser
  class << self
    def parse(argv)
      CommandLineParser.new(argv).do_parse
    end
  end

  def initialize(argv)
    @input = nil
    @output = nil
    @type = "ncurses"
    @time = 1
    @argv = argv
  end

  attr_reader :input, :output, :type, :time

  def do_parse
    skip_next = false
    @argv.each_with_index do |arg, i|
      skip_next = skip_next ? false : handle_arg(arg, i)
    end

    if @output and @output == @input
      $stderr.puts "don't use the input file name as the output filename to prevent overwriting it. \n"
      exit(1)
    end
    self
  end

  def usage
    $stderr.puts "usage: #{$0} [-t <type> -o <file>] <file>\n"
    $stderr.puts "\t -t <type>\tset filetype <type> as output format"
    $stderr.puts "\t -o <file>\twrite output to file <file>"
    $stderr.puts "\t -s <seconds>\twait <seconds> seconds between slides (with -t autoplay)"
    $stderr.puts "\t --version\tprint the version"
    $stderr.puts "\t --help\t\tprint this help"
    $stderr.puts "\n\t currently available types: ncurses (default), autoplay, latex, txt"
    exit(1)
  end

  def show_version
    puts "tpp - text presentation program #{VERSION_NUMBER}\n"
    usage
  end

  private

  def handle_arg(arg, i)
    case arg
    when '-v', '--version'
      show_version
    when '-h', '--help'
      usage
    when '-t'
      @type = @argv[i+1]
      return true
    when '-o'
      @output = @argv[i+1]
      return true
    when "-s"
      @time = @argv[i+1].to_i
      return true
    else
      @input = arg unless @input
    end
    false
  end
end
