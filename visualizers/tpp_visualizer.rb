# Implements a generic visualizer from which all other visualizers need to be 
# derived. If Ruby supported abstract methods, all the do_* methods would be 
# abstract.
class TppVisualizer

  def initialize; end

  # Splits a line into several lines, where each of the result lines is at most 
  # _width_ characters long, caring about word boundaries, and returns an array 
  # of strings.
  def split_lines(text,width)
    return [] unless text
    text.gsub(/(.{1,#{width}})( +|$\n?)|(.{1,#{width}})/).to_a
  end

  def print_line(line)
    $stderr.puts "Error: TppVisualizer#print_line has been called directly."
    Kernel.exit(1)
  end

  [
    :title, :author, :date,
    :bgcolor, :fgcolor, :color,
    :header, :heading, :footer,
    :huge,
    :center, :right,
    :exec, :sleep
  ].map { |suffix| "do_#{suffix}".to_sym }.each do |method|
    define_method method do |meth_param|
      $stderr.puts "Error: TppVisualizer#do_heading has been called directly."
      Kernel.exit(1)
    end
  end

  def new_page
    $stderr.puts "Error: TppVisualizer#new_page has been called directly."
    Kernel.exit(1)
  end

  [
    :command_prompt,
    :sethugefont,
    :withborder, :horline,
    :beginoutput, :wait, :endoutput,
    :beginshelloutput, :endshelloutput,
    :boldon, :boldoff,
    :revon, :revoff,
    :ulon, :uloff,
    :beginslideleft, :beginslideright,
    :beginslidetop, :beginslidebottom,
    :refresh, :endslide
  ].map { |suffix| "do_#{suffix}".to_sym }.each do |do_method|
    define_method do_method do
      $stderr.puts "Error: TppVisualizer##{do_method} has been called directly."
      Kernel.exit(1)
    end
  end

  # Receives a _line_, parses it if necessary, and dispatches it 
  # to the correct method which then does the correct processing.
  # It returns whether the controller shall wait for input.
  def visualize(line,eop)
    case line
      when /^--heading /
        text = line.sub(/^--heading /,"")
        do_heading(text)
      when /^--withborder/
        do_withborder
      when /^--horline/
        do_horline
      when /^--color /
        text = line.sub(/^--color /,"")
        text.strip!
        do_color(text)
      when /^--center /
        text = line.sub(/^--center /,"")
        do_center(text)
      when /^--right /
        text = line.sub(/^--right /,"")
        do_right(text)
      when /^--exec /
        cmdline = line.sub(/^--exec /,"")
        do_exec(cmdline)
      when /^---/
        do_wait
        return true
      when /^--beginoutput/
        do_beginoutput
      when /^--beginshelloutput/
        do_beginshelloutput
      when /^--endoutput/
        do_endoutput
      when /^--endshelloutput/
        do_endshelloutput
      when /^--sleep /
        time2sleep = line.sub(/^--sleep /,"")
        do_sleep(time2sleep)
      when /^--boldon/
        do_boldon
      when /^--boldoff/
        do_boldoff
      when /^--revon/
        do_revon
      when /^--revoff/
        do_revoff
      when /^--ulon/
        do_ulon
      when /^--uloff/
        do_uloff
      when /^--beginslideleft/
        do_beginslideleft
      when /^--endslideleft/, /^--endslideright/, /^--endslidetop/, /^--endslidebottom/
        do_endslide
      when /^--beginslideright/
        do_beginslideright
      when /^--beginslidetop/
        do_beginslidetop
      when /^--beginslidebottom/
        do_beginslidebottom
      when /^--sethugefont /
        params = line.sub(/^--sethugefont /,"")
        do_sethugefont(params.strip)
      when /^--huge /
        figlet_text = line.sub(/^--huge /,"")
        do_huge(figlet_text)
      when /^--footer /
        @footer_txt = line.sub(/^--footer /,"")
        do_footer(@footer_txt) 
      when /^--header /
        @header_txt = line.sub(/^--header /,"")
        do_header(@header_txt) 
      when /^--title /
        title = line.sub(/^--title /,"")
        do_title(title)
      when /^--author /
        author = line.sub(/^--author /,"")
        do_author(author)
      when /^--date /
        date = line.sub(/^--date /,"")
        if date == "today" then
          date = Time.now.strftime("%b %d %Y")
        elsif date =~ /^today / then
          date = Time.now.strftime(date.sub(/^today /,""))
        end
        do_date(date)
      when /^--bgcolor /
        color = line.sub(/^--bgcolor /,"").strip
        do_bgcolor(color)
      when /^--fgcolor /
        color = line.sub(/^--fgcolor /,"").strip
        do_fgcolor(color)
      when /^--color /
        color = line.sub(/^--color /,"").strip
        do_color(color)
    else
      print_line(line)
    end

    return false
  end

  def close; end

end

