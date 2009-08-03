# ruby ~ whiner_tools.rb

module WhinerTools
  VERSION = "0.0.1" unless defined?(VERSION)
end

require File.dirname(__FILE__)+'/whiner_tools/logger'
require File.dirname(__FILE__)+'/whiner_tools/global'