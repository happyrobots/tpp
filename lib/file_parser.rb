# Opens a TPP source file, and splits it into the different pages.
class FileParser

  def initialize(filename)
    @filename = filename
    @pages = []
  end

  # Parses the specified file and returns an array of Page objects
  def get_pages
    begin
      file = File.open(@filename)
    rescue
      $stderr.puts "Error: couldn't open file: #{$!}"
      Kernel.exit(1)
    end

    @number_pages = 1
    @cur_page = Page.new default_slide_name
    @pages << @cur_page
    file.each_line { |line| handle_line(line) }
    @pages
  end

  private

  def default_slide_name
    "slide #{@number_pages}"
  end

  def handle_line(line)
    line.chomp!

    case line
    when /^--##/ # ignore comments
    when /^--newpage/
      @number_pages += 1
      name = line.sub(/^--newpage/,"")
      if name.empty?
        name = default_slide_name
      else
        name.strip!
      end
      @cur_page = Page.new(name)
      @pages << @cur_page
    else
      @cur_page.add_line(line)
    end
  end
end
