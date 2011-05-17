# Implements an interactive controller which feeds the visualizer until it is 
# told to stop, and then reads a key press and executes the appropiate action.
class InteractiveController < TppController

  def initialize(filename,visualizer_class)
    @filename = filename
    @vis = visualizer_class.new
    @cur_page = 0
  end

  def close
    @vis.close
  end

  def run
    begin
      @reload_file = false
      parser = FileParser.new(@filename)
      @pages = parser.get_pages
      @cur_page = @pages.size - 1 if @cur_page >= @pages.size
      @vis.clear
      @vis.new_page
      do_run
    end while @reload_file
  end

  def do_run
    loop do
      wait = false
      @vis.draw_slidenum(@cur_page + 1, @pages.size, false)
      # read and visualize lines until the visualizer says "stop" or we reached end of page
      begin
        line = @pages[@cur_page].next_line
        @eop = @pages[@cur_page].eop?
        wait = @vis.visualize(line,@eop)
      end while not wait and not @eop
      # draw slide number on the bottom left and redraw:
      @vis.draw_slidenum(@cur_page + 1, @pages.size, @eop)
      @vis.do_refresh

      # read a character from the keyboard
      # a "break" in the when means that it breaks the loop, i.e. goes on with visualizing lines
      loop do
        action = handle_key @vis.get_key
        case action
        when "return"
          return
        when "break"
          break
        end
      end
    end
  end

  private
  def handle_key(ch)
    case ch
    when 'q'[0], 'Q'[0] # 'Q'uit
      return "return"
    when 'r'[0], 'R'[0] # 'R'edraw slide
      changed_page = true # @todo: actually implement redraw
    when 'e'[0], 'E'[0]
      @cur_page = @pages.size - 1
      return "break"
    when 's'[0], 'S'[0]
      @cur_page = 0
      return "break"
    when 'j'[0], 'J'[0] # 'J'ump to slide
      screen = @vis.store_screen
      p = @vis.read_newpage(@pages,@cur_page)
      if p >= 0 and p < @pages.size
        @cur_page = p
        @pages[@cur_page].reset_eop
        @vis.new_page
      else
        @vis.restore_screen(screen)
      end
      return "break"
    when 'l'[0], 'L'[0] # re'l'oad current file
      @reload_file = true
      return "return"
    when 'c'[0], 'C'[0] # command prompt
      screen = @vis.store_screen
      @vis.do_command_prompt
      @vis.clear
      @vis.restore_screen(screen)
    when '?'[0], 'h'[0]
      screen = @vis.store_screen
      @vis.show_help_page
      ch = @vis.get_key
      @vis.clear
      @vis.restore_screen(screen)
    when :keyright, :keydown, ' '[0]
      if @cur_page + 1 < @pages.size and @eop then
        @cur_page += 1
        @pages[@cur_page].reset_eop
        @vis.new_page
      end
      return "break"
    when 'b'[0], 'B'[0], :keyleft, :keyup
      if @cur_page > 0 then
        @cur_page -= 1
        @pages[@cur_page].reset_eop
        @vis.new_page
      end
      return "break"
    when :keyresize
      @vis.setsizes
    end
    nil
  end
end
