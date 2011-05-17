#!/usr/bin/env ruby

VERSION_NUMBER = "1.3.1.1"

dependencies = [
  'rubygems',
  'ncurses',
  'ruby-event',
  'visualizers/tpp_visualizer',
  'controllers/tpp_controller'
]

autoload_paths = [
  'lib/*.rb',
  'visualizers/*.rb',
  'controllers/*.rb'
]

begin
  dependencies.each { |dep| require dep }
  autoload_paths.each { |path| Dir[path].each { |dep| require dep } }
  include Ncurses
  include ColorMap
rescue LoadError => e
  p e
  $stderr.print <<EOF
There is no Ncurses-Ruby package installed which is needed by TPP.
You can download it on: http://ncurses-ruby.berlios.de/
EOF
  exit(1)
end

clp = CommandLineParser.parse ARGV
clp.usage unless clp.input

controller = TppController.build_controller(clp)
clp.usage unless controller

controller.run
controller.close
