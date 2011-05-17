# Maps color names to constants and indexes.
module ColorMap

  COLOR_INDICES = {
    "white"   => 1,
    "yellow"  => 2,
    "red"     => 3,
    "green"   => 4,
    "blue"    => 5,
    "cyan"    => 6,
    "magenta" => 7,
    "black"   => 8,
    "default" =>-1
  }

  # Maps color name _color_ to a constant
  def get_color(color)
    colors = {
      "white"   => COLOR_WHITE,
      "yellow"  => COLOR_YELLOW,
      "red"     => COLOR_RED,
      "green"   => COLOR_GREEN,
      "blue"    => COLOR_BLUE,
      "cyan"    => COLOR_CYAN,
      "magenta" => COLOR_MAGENTA,
      "black"   => COLOR_BLACK,
      "default" => -1
    }
    colors[color]
  end

  # Maps color name to a color pair index
  def get_color_pair(color)
    COLOR_INDICES[color]
  end
end
