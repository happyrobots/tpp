# Implements an interactive visualizer which builds on top of ncurses.
class NcursesVisualizer < TppVisualizer

  def initialize
    @figletfont = "standard"
    Ncurses.initscr
    Ncurses.curs_set(0)
    Ncurses.cbreak # unbuffered input
    Ncurses.noecho # turn off input echoing
    Ncurses.stdscr.intrflush(false)
    Ncurses.stdscr.keypad(true)
    @screen = Ncurses.stdscr
    setsizes
    Ncurses.start_color()
    Ncurses.use_default_colors()
    do_bgcolor("black")
    #do_fgcolor("white")
    @fgcolor = ColorMap.get_color_pair("white")
    @voffset = 5
    @indent = 3
    @cur_line = @voffset
    @output = @shelloutput = false
  end

  def get_key
    ch = @screen.getch
    case ch
      when Ncurses::KEY_RIGHT
        return :keyright
      when Ncurses::KEY_DOWN
        return :keydown
      when Ncurses::KEY_LEFT
        return :keyleft
      when Ncurses::KEY_UP
        return :keyup
      when Ncurses::KEY_RESIZE
        return :keyresize
      else
        return ch
      end
  end

  def clear
    @screen.clear
    @screen.refresh
  end


  def setsizes
    @termwidth = Ncurses.getmaxx(@screen)
    @termheight = Ncurses.getmaxy(@screen)
  end

  def do_refresh
    @screen.refresh
  end

  def do_withborder
    @withborder = true
    draw_border
  end
  
  def do_command_prompt()
    message = "Press any key to continue :)"
    cursor_pos = 0
    max_len = 50
    prompt = "tpp@localhost:~ $ "
    string = ""
    window = @screen.dupwin
    Ncurses.overwrite(window,@screen) # overwrite @screen with window
    Ncurses.curs_set(1)
    Ncurses.echo
    window.move(@termheight/4,1)
    window.clrtoeol()
    window.clrtobot()
    window.mvaddstr(@termheight/4,1,prompt) # add the prompt string

    loop do
      window.mvaddstr(@termheight/4,1+prompt.length,string) # add the code
      window.move(@termheight/4,1+prompt.length+cursor_pos) # move cursor to the end of code
      ch = window.getch
      case ch
        when Ncurses::KEY_ENTER, ?\n, ?\r
          Ncurses.curs_set(0)
          Ncurses.noecho
          rc = Kernel.system(string)
          if not rc then
            @screen.mvaddstr(@termheight/4+1,1,"Error: exec \"#{string}\" failed with error code #{$?}")
            @screen.mvaddstr(@termheight-2,@termwidth/2-message.length/2,message)
          end
          if rc then
            @screen.mvaddstr(@termheight-2,@termwidth/2-message.length/2,message)
            ch = Ncurses.getch()
            @screen.refresh
          end
          return
        when Ncurses::KEY_LEFT
          cursor_pos = [0, cursor_pos-1].max # jump one character to the left
        when Ncurses::KEY_RIGHT
          cursor_pos = [0, cursor_pos+1].max # jump one character to the right
        when Ncurses::KEY_BACKSPACE
          string = string[0...([0, cursor_pos-1].max)] + string[cursor_pos..-1]
          cursor_pos = [0, cursor_pos-1].max
          window.mvaddstr(@termheight/4, 1+prompt.length+string.length, " ")
        when " "[0]..255
          if (cursor_pos < max_len)
            string[cursor_pos,0] = ch.chr
            cursor_pos += 1
          else
            Ncurses.beep
          end
      else
          Ncurses.beep
      end
    end
    Ncurses.curs_set(0)

  end

  def draw_border
    @screen.move(0,0)
    @screen.addstr(".")
    (@termwidth-2).times { @screen.addstr("-") }; @screen.addstr(".")
    @screen.move(@termheight-2,0)
    @screen.addstr("`")
    (@termwidth-2).times { @screen.addstr("-") }; @screen.addstr("'")
    1.upto(@termheight-3) do |y|
      @screen.move(y,0)
      @screen.addstr("|") 
    end
    1.upto(@termheight-3) do |y|
      @screen.move(y,@termwidth-1)
      @screen.addstr("|") 
    end
  end

  def new_page
    @cur_line = @voffset
    @output = @shelloutput = false
    setsizes
    @screen.clear
  end

  def do_heading(line)
    @screen.attron(Ncurses::A_BOLD)
    print_heading(line)
    @screen.attroff(Ncurses::A_BOLD)
  end

  def do_horline
    @screen.attron(Ncurses::A_BOLD)
    @termwidth.times do |x|
      @screen.move(@cur_line,x)
      @screen.addstr("-")
    end
    @screen.attroff(Ncurses::A_BOLD)
  end

  def print_heading(text)
    width = @termwidth - 2*@indent
    lines = split_lines(text,width)
    lines.each do |l|
      @screen.move(@cur_line,@indent)
      x = (@termwidth - l.length)/2
      @screen.move(@cur_line,x)
      @screen.addstr(l)
      @cur_line += 1
    end
  end

  def do_center(text)
    width = @termwidth - 2*@indent
    width -= 2 if @output or @shelloutput
    lines = split_lines(text,width)
    lines.each do |l|
      @screen.move(@cur_line,@indent)
      @screen.addstr("| ") if @output or @shelloutput
      x = (@termwidth - l.length)/2
      @screen.move(@cur_line,x)
      @screen.addstr(l)
      if @output or @shelloutput then
        @screen.move(@cur_line,@termwidth - @indent - 2)
        @screen.addstr(" |")
      end
      @cur_line += 1
    end
  end

  def do_right(text)
    width = @termwidth - 2*@indent
    width -= 2 if @output or @shelloutput
    lines = split_lines(text,width)
    lines.each do |l|
      @screen.move(@cur_line,@indent)
      @screen.addstr("| ") if @output or @shelloutput
      x = (@termwidth - l.length - 5)
      @screen.move(@cur_line,x)
      @screen.addstr(l)
      @screen.addstr(" |") if @output or @shelloutput
      @cur_line += 1
    end
  end

  def show_help_page
    help_text = [ "tpp help", 
                  "",
                  "space bar ............................... display next entry within page",
                  "space bar, cursor-down, cursor-right .... display next page",
                  "b, cursor-up, cursor-left ............... display previous page",
                  "q, Q .................................... quit tpp",
                  "j, J .................................... jump directly to page",
                  "l, L .................................... reload current file",
                  "s, S .................................... jump to the first page",
                  "e, E .................................... jump to the last page",
                  "c, C .................................... start command line",
                  "?, h .................................... this help screen" ]
    @screen.clear
    y = @voffset
    help_text.each do |line|
      @screen.move(y,@indent)
      @screen.addstr(line)
      y += 1
    end
    @screen.move(@termheight - 2, @indent)
    @screen.addstr("Press any key to return to slide")
    @screen.refresh
  end

  def do_exec(cmdline)
    rc = Kernel.system(cmdline)
    if not rc then
      # @todo: add error message
    end
  end

  def do_wait; end

  def do_beginoutput
    @screen.move(@cur_line,@indent)
    @screen.addstr(".")
    (@termwidth - @indent*2 - 2).times { @screen.addstr("-") }
    @screen.addstr(".")
    @output = true
    @cur_line += 1
  end

  def do_beginshelloutput
    @screen.move(@cur_line,@indent)
    @screen.addstr(".")
    (@termwidth - @indent*2 - 2).times { @screen.addstr("-") }
    @screen.addstr(".")
    @shelloutput = true
    @cur_line += 1
  end

  def do_endoutput
    if @output
      @screen.move(@cur_line,@indent)
      @screen.addstr("`")
      (@termwidth - @indent*2 - 2).times { @screen.addstr("-") }
      @screen.addstr("'")
      @output = false
      @cur_line += 1
    end
  end

  def do_title(title)
    do_boldon
    do_center(title)
    do_boldoff
    do_center("")
  end

  def do_footer(footer_txt)
    @screen.move(@termheight - 3, (@termwidth - footer_txt.length)/2)
    @screen.addstr(footer_txt)
  end
 
 def do_header(header_txt)
    @screen.move(@termheight - @termheight+1, (@termwidth - header_txt.length)/2)
    @screen.addstr(header_txt)
  end

  def do_author(author)
    do_center(author)
    do_center("")
  end

  def do_date(date)
    do_center(date)
    do_center("")
  end

  def do_endshelloutput
    if @shelloutput then
      @screen.move(@cur_line,@indent)
      @screen.addstr("`")
      (@termwidth - @indent*2 - 2).times { @screen.addstr("-") }
      @screen.addstr("'")
      @shelloutput = false
      @cur_line += 1
    end
  end

  def do_sleep(time2sleep)
    Kernel.sleep(time2sleep.to_i)
  end

  def do_boldon
    @screen.attron(Ncurses::A_BOLD)
  end

  def do_boldoff
    @screen.attroff(Ncurses::A_BOLD)
  end

  def do_revon
    @screen.attron(Ncurses::A_REVERSE)
  end

  def do_revoff
    @screen.attroff(Ncurses::A_REVERSE)
  end

  def do_ulon
    @screen.attron(Ncurses::A_UNDERLINE)
  end

  def do_uloff
    @screen.attroff(Ncurses::A_UNDERLINE)
  end

  def do_beginslideleft
    @slideoutput = true
    @slidedir = "left"
  end

  def do_endslide
    @slideoutput = false
  end

  def do_beginslideright
    @slideoutput = true
    @slidedir = "right"
  end

  def do_beginslidetop
    @slideoutput = true
    @slidedir = "top"
  end

  def do_beginslidebottom
    @slideoutput = true
    @slidedir = "bottom"
  end

  def do_sethugefont(params)
    @figletfont = params
  end

  def do_huge(figlet_text)
    output_width = @termwidth - @indent
    output_width -= 2 if @output or @shelloutput
    op = IO.popen("figlet -f #{@figletfont} -w #{output_width} -k \"#{figlet_text}\"","r")
    op.readlines.each { |line| print_line(line) }
    op.close
  end

  def do_bgcolor(color)
    bgcolor = ColorMap.get_color(color) or COLOR_BLACK
    Ncurses.init_pair(1, COLOR_WHITE, bgcolor)
    Ncurses.init_pair(2, COLOR_YELLOW, bgcolor)
    Ncurses.init_pair(3, COLOR_RED, bgcolor)
    Ncurses.init_pair(4, COLOR_GREEN, bgcolor)
    Ncurses.init_pair(5, COLOR_BLUE, bgcolor)
    Ncurses.init_pair(6, COLOR_CYAN, bgcolor)
    Ncurses.init_pair(7, COLOR_MAGENTA, bgcolor)
    Ncurses.init_pair(8, COLOR_BLACK, bgcolor)
    if @fgcolor
      Ncurses.bkgd(Ncurses.COLOR_PAIR(@fgcolor))
    else
      Ncurses.bkgd(Ncurses.COLOR_PAIR(1))
    end
  end

  def do_fgcolor(color)
    @fgcolor = ColorMap.get_color_pair(color)
    Ncurses.attron(Ncurses.COLOR_PAIR(@fgcolor))
  end

  def do_color(color)
    num = ColorMap.get_color_pair(color)
    Ncurses.attron(Ncurses.COLOR_PAIR(num))
  end

  def type_line(l)
    l.each_byte do |x|
      @screen.addstr(x.chr)
      @screen.refresh()
      r = rand(20)
      time_to_sleep = (5 + r).to_f / 250;
      # puts "#{time_to_sleep} #{r}"
      Kernel.sleep(time_to_sleep)
    end
  end

  def slide_text(l)
    return if l == ""
    case @slidedir
    when "left"
      xcount = l.length-1
      while xcount >= 0
        @screen.move(@cur_line,@indent)
        @screen.addstr(l[xcount..l.length-1])
        @screen.refresh()
        time_to_sleep = 1.to_f / 20
        Kernel.sleep(time_to_sleep)
        xcount -= 1
      end  
    when "right"
      (@termwidth - @indent).times do |pos|
        @screen.move(@cur_line,@termwidth - pos - 1)
        @screen.clrtoeol()
        maxpos = (pos >= l.length-1) ? l.length-1 : pos
        @screen.addstr(l[0..pos])
        @screen.refresh()
        time_to_sleep = 1.to_f / 20
        Kernel.sleep(time_to_sleep)
      end # do
    when "top"
      # ycount = @cur_line
      new_scr = @screen.dupwin
      1.upto(@cur_line) do |i|
        Ncurses.overwrite(new_scr,@screen) # overwrite @screen with new_scr
        @screen.move(i,@indent)
        @screen.addstr(l)
        @screen.refresh()
        Kernel.sleep(1.to_f / 10)
      end
    when "bottom"
      new_scr = @screen.dupwin
      (@termheight-1).downto(@cur_line) do |i|
        Ncurses.overwrite(new_scr,@screen)
        @screen.move(i,@indent)
        @screen.addstr(l)
        @screen.refresh()
        Kernel.sleep(1.to_f / 10)
      end
    end
  end

  def print_line(line)
    width = @termwidth - 2*@indent
    width -= 2 if @output or @shelloutput
    lines = split_lines(line,width)
    lines.each do |l|
      @screen.move(@cur_line,@indent)
      @screen.addstr("| ") if (@output or @shelloutput) and ! @slideoutput
      if @shelloutput and (l =~ /^\$/ or l=~ /^%/ or l =~ /^#/) then # allow sh and csh style prompts
        type_line(l)
      elsif @slideoutput then
        slide_text(l)
      else
        @screen.addstr(l)
      end

      if (@output or @shelloutput) and ! @slideoutput then
        @screen.move(@cur_line,@termwidth - @indent - 2)
        @screen.addstr(" |")
      end
      @cur_line += 1
    end
  end

  def close
    Ncurses.nocbreak
    Ncurses.endwin
  end

  def read_newpage(pages,current_page)
    page = []
    @screen.clear()
    col = 0
    line = 2
    pages.each_index do |i|
      @screen.move(line,col*15 + 2)
      if current_page == i then
        @screen.printw("%2d %s <=",i+1,pages[i].title[0..80])
      else  
        @screen.printw("%2d %s",i+1,pages[i].title[0..80])
      end
      line += 1
      if line >= @termheight - 3 then
        line = 2
        col += 1
      end
    end
    prompt = "jump to slide: "
    prompt_indent = 12
    @screen.move(@termheight - 2, @indent + prompt_indent)
    @screen.addstr(prompt)
    # @screen.refresh();
    Ncurses.echo
    @screen.scanw("%d",page)
    Ncurses.noecho
    @screen.move(@termheight - 2, @indent + prompt_indent)
    (prompt.length + page[0].to_s.length).times { @screen.addstr(" ") }
    return page[0] - 1 if page[0]
    return -1 # invalid page
  end

  def store_screen
    @screen.dupwin
  end

  def restore_screen(s)
    Ncurses.overwrite(s,@screen)
  end

  def draw_slidenum(cur_page,max_pages,eop)
    @screen.move(@termheight - 2, @indent)
    @screen.attroff(Ncurses::A_BOLD) # this is bad
    @screen.addstr("[slide #{cur_page}/#{max_pages}]")
	  do_footer(@footer_txt) if @footer_txt.to_s.length > 0
    do_header(@header_txt) if @header_txt.to_s.length > 0
    draw_eop_marker if eop
  end

  def draw_eop_marker
    @screen.move(@termheight - 2, @indent - 1)
    @screen.attron(A_BOLD)
    @screen.addstr("*")
    @screen.attroff(A_BOLD)
  end

end

