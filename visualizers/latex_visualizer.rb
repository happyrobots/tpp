# Implements a visualizer which converts TPP source to LaTeX-beamer source (http://latex-beamer.sf.net/
class LatexVisualizer < TppVisualizer

  def initialize(outputfile)
    @filename = outputfile
    begin
      @f = File.open(@filename,"w+")
    rescue
      $stderr.print "Error: couldn't open file: #{$!}"
      Kernel.exit(1)
    end
    @slide_open = false
    @verbatim_open = false
    @width = 50
    @title = @date = @author = false
    @begindoc = false
    @f.puts '% Filename:      tpp.tex
% Purpose:       template file for tpp latex export
% Authors:       (c) Andreas Gredler, Michael Prokop http://grml.org/
% License:       This file is licensed under the GPL v2.
% Latest change: Fre Apr 15 20:34:37 CEST 2005
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\documentclass{beamer}

\mode<presentation>
{
  \usetheme{Montpellier}
  \setbeamercovered{transparent}
}

\usepackage[german]{babel}
\usepackage{umlaut}
\usepackage[latin1]{inputenc}
\usepackage{times}
\usepackage[T1]{fontenc}

'
  end

  [
    :header, :footer,
    :color, :exec, :sleep,
    :sethugefont, :huge,
    :bgcolor, :fgcolor, :color
  ].map { |meth| "do_#{meth}".to_sym }.each do |do_method|
    define_method do_method do |param| ; end
  end

  [
    :command_prompt,
    :refresh, :withborder, :horline,
    :wait, :beginshelloutput, :endoutput, :endshelloutput,
    :ulon, :uloff,
    :boldon, :boldoff,
    :revon, :revoff,
    :beginslideleft, :beginslideright,
    :beginslidetop, :beginslidebottom,
    :endslide
  ].map { |meth| "do_#{meth}".to_sym }.each do |do_method|
    define_method do_method do; end
  end

  def try_close
    if @verbatim_open then
      @f.puts '\end{verbatim}'
      @verbatim_open = false
    end
    if @slide_open then
      @f.puts '\end{frame}'
      @slide_open = false
    end
  end

  def new_page
    try_close
  end

  def do_heading(text)
    try_close
    @f.puts "\\section{#{text}}"
  end

  def do_center(text)
    print_line(text)
  end

  def do_right(text)
    print_line(text)
  end

  def do_beginoutput
    # TODO: implement output stuff
  end

  def try_open
    unless @begindoc
      @f.puts '\begin{document}'
      @begindoc = true
    end
    unless @slide_open
      @f.puts '\begin{frame}[fragile]'
      @slide_open = true
    end
    unless @verbatim_open
      @f.puts '\begin{verbatim}'
      @verbatim_open = true
    end
  end

  def try_intro
    if @author and @title and @date and not @begindoc then
      @f.puts '\begin{document}'
      @begindoc = true
    end
    if @author and @title and @date then
      @f.puts '\begin{frame}
        \titlepage
      \end{frame}'
    end
  end

  def print_line(line)
    try_open
    split_lines(line,@width).each do |l|
      @f.puts "#{l}"
    end
  end

  def do_title(title)
    @f.puts "\\title[#{title}]{#{title}}"
    @title = true
    try_intro
  end

  def do_author(author)
    @f.puts "\\author{#{author}}"
    @author = true
    try_intro
  end

  def do_date(date)
    @f.puts "\\date{#{date}}"
    @date = true
    try_intro
  end

  def close
    try_close
    @f.puts '\end{document}
    %%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    @f.close
  end

end

