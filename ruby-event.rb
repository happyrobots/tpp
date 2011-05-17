# ruby-event - ruby-event.rb
# Author    :: Stefan Nuxoll
# License   :: BSD License
# Copyright :: Copyright (C) 2009 Stefan Nuxoll
module RubyEvent
  require 'ruby-event/event'
  require 'ruby-event/generator'
end

Object.extend(RubyEvent::Generator)
