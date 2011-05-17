# Implements a non-interactive controller for ncurses. Useful for displaying
# unattended presentation.
class AutoplayController < TppController

  def initialize(filename,secs,visualizer_class)
    @filename = filename
    @vis = visualizer_class.new
    @seconds = secs
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
      if @cur_page >= @pages.size then
        @cur_page = @pages.size - 1
      end
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
        eop = @pages[@cur_page].eop?
        wait = @vis.visualize(line,eop)
      end while not wait and not eop
      # draw slide number on the bottom left and redraw:
      @vis.draw_slidenum(@cur_page + 1, @pages.size, eop)
      @vis.do_refresh

      if eop then
        if @cur_page + 1 < @pages.size then
          @cur_page += 1
        else
          @cur_page = 0
        end
        @pages[@cur_page].reset_eop
        @vis.new_page
      end

      Kernel.sleep(@seconds)
    end # loop
  end

end

