# Implements a non-interactive controller to control non-interactive 
# visualizers (i.e. those that are used for converting TPP source code into 
# another format)
class ConversionController < TppController

  def initialize(input,output,visualizer_class)
    parser = FileParser.new(input)
    @pages = parser.get_pages
    @vis = visualizer_class.new(output)
  end

  def run
    @pages.each do |p|
      begin
        line = p.next_line
        eop = p.eop?
        @vis.visualize(line,eop)
      end while not eop
    end
  end

  def close
    @vis.close
  end

end
