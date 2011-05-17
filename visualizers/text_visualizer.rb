# Implements a visualizer which converts TPP source to a nicely formatted text 
# file which can e.g. be used as handout.
class TextVisualizer < TppVisualizer

  def initialize(outputfile)
    @filename = outputfile
    begin
      @f = File.open(@filename,"w+")
    rescue
      $stderr.print "Error: couldn't open file: #{$!}"
      Kernel.exit(1)
    end
    @output_env = false
    @title = @author = @date = false
    @figletfont = "small"
    @width = 80
  end

  def new_page
    @f.puts "--------------------------------------------"
  end

  def do_heading(text)
    @f.puts "\n"
    split_lines(text,@width).each { |l| @f.puts "#{l}\n" }
    @f.puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  end

  def do_horline
    @f.puts "********************************************"
  end

  def do_beginoutput
    @f.puts ".---------------------------"
    @output_env = true
  end

  def do_beginshelloutput
    do_beginoutput
  end

  def do_endoutput
    @f.puts "`---------------------------"
    @output_env = false
  end

  def do_endshelloutput
    do_endoutput
  end

  [
    :footer, :header,
    :bgcolor, :fgcolor,
    :sleep, :color, :exec
  ].map { |meth| "do_#{meth}".to_sym }.each do |do_method|
    define_method do_method do |param| ; end
  end

  [
    :boldon, :boldoff,
    :revon, :revoff,
    :command_prompt,
    :ulon, :uloff,
    :beginslideleft, :beginslideright,
    :beginslidetop, :beginslidebottom,
    :endslide, :wait, :withborder, :refresh
  ].map { |meth| "do_#{meth}".to_sym }.each do |do_method|
    define_method do_method do; end
  end

  def do_sethugefont(text)
    @figletfont = text
  end

  def do_huge(text)
    output_width = @width
    output_width -= 2 if @output_env
    op = IO.popen("figlet -f #{@figletfont} -w @output_width -k \"#{text}\"","r")
    op.readlines.each { |line| print_line(line) }
    op.close
  end

  def print_line(line)
    lines = split_lines(line,@width)
    lines.each do |l|
      if @output_env then
        @f.puts "| #{l}"
      else
        @f.puts "#{l}"
      end
    end
  end

  def do_center(text)
    lines = split_lines(text,@width)
    lines.each do |line|
      spaces = (@width - line.length) / 2
      spaces = 0 if spaces < 0
      spaces.times { line = " " + line }
      print_line(line)
    end
  end

  def do_right(text)
    lines = split_lines(text,@width)
    lines.each do |line|
      spaces = @width - line.length
      spaces = 0 if spaces < 0
      spaces.times { line = " " + line }
      print_line(line)
    end
  end

  def do_title(title)
    @f.puts "Title: #{title}"
    @title = true
    @f.puts "\n\n" if @title and @author and @date
  end

  def do_author(author)
    @f.puts "Author: #{author}"
    @author = true
    @f.puts "\n\n" if @title and @author and @date
  end

  def do_date(date)
    @f.puts "Date: #{date}"
    @date = true
    @f.puts "\n\n" if @title and @author and @date
  end

  def close
    @f.close
  end

end

