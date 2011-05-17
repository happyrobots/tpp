# Represents a page (aka `slide') in TPP. A page consists of a title and one or 
# more lines.
class Page

  def initialize(title)
    @lines = []
    @title = title
    @cur_line = 0
    @eop = false
  end

  # Appends a line to the page, but only if _line_ is not null
  def add_line(line)
    @lines << line if line
  end

  # Returns the next line. In case the last line is hit, then the end-of-page marker is set.
  def next_line
    line = @lines[@cur_line]
    @cur_line += 1
    @eop = true if @cur_line >= @lines.size
    line
  end

  # Returns whether end-of-page has been reached.
  def eop?
    @eop
  end

  # Resets the end-of-page marker and sets the current line marker to the first line
  def reset_eop
    @cur_line = 0
    @eop = false
  end

  attr_reader :lines, :title
end
