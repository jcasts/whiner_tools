# Use 'whine' to make information about a specific category visible.
# whine outputs are grouped by default but can output inline if the :inline 
# option is set:
#  whine :about => "Stuff", :say => "I'm such a whiner", :inline => true
# A :backtrace option can also be set:
#  whine :about => "Politics", :say => "they suck!", :backtrace => 2
#  whine :about => "Craziness", :say => "I love crazy things!", :backtrace => :all
# The :backtrace option supports booleans, integers, and ranges.
def whine(options={})
  message_hash = {options.delete(:about) => options.delete(:say)}
  WhinerTools.print(message_hash, options)
end


# Use 'deprecated' to flag a method as deprecated and raise a warning.
#  deprecated :use => "new_method"
#    #=> "Deprecation Warning: '#{caller[0]}' is deprecated. Use 'new_method'."
#  deprecated :was => "old_method", :use => "new_method"
#    #=> "Deprecation Warning: 'old_method' is deprecated. Use 'new_method'."
#  deprecated :message => "Don't use this!"
#    #=> "Deprecation Warning: Don't use this!"
def deprecated(options={})
  method_match = caller[0].match(/in\s`(.+)'$/)
  old_method = options[:was]
  old_method ||= method_match ? method_match[1] : caller[0]
  new_implementation = options[:use] ? " Use '#{options[:use]}'." : ""
  
  message = options[:message] || "'#{old_method}' is deprecated.#{new_implementation}"
  message = "#{message}\n   from: #{(caller[1] || caller.last)}"
  
  whine :about => "Deprecation", :say => message
end


# Documents TODOs.
#  TODO %{This is stuff to do. DON'T FORGET!!!}
#   #=> "TODO [#{caller[0]}]: This is stuff to do. DON'T FORGET!!!"
# Avoid calling TODO from methods as it will output TODOs repetedly.
# Options are the standard whiner options: :inline and :backtrace
def TODO(msg="(no-info)", options={})
  whine( {:about => "TODOs", :say => "[#{caller[0]}]: #{msg}"}.merge(options) )
end


# Sets up a default logger accessible from the 'logger' method.
#  setup_logger
#    #=> <WhinerTools::Logger:0x12a39a0 @targets=[#<WhinerTools::Logger::Target:0x12a393c @out=#<IO:0x2f7d8>, @log_level=0>]>
#  setup_logger File.open("log_file.txt"), :level => 1
#    #=> <WhinerTools::Logger:0x12a39a0 @targets=[#<WhinerTools::Logger::Target:0x12a393c @out=#<File:0x78bb9>, @log_level=1>]>
#  setup_logger do |logger|
#    logger.add_target File.open("log_file.txt"), :level => 1
#    logger.add_target IO.popen("some_irc_pipe_for_fatal_logs"), :level => 4
#  end
#    #=> <WhinerTools::Logger:0x12a39a0 @targets=[#<WhinerTools::Logger::Target:0x12a393c @out=#<File:0x78bb9>, @log_level=1>, #<WhinerTools::Logger::Target:0x12a393c @out=#<IO:0x2f7d8>, @log_level=4>]>
#  setup_logger $stdout, :format => "$L [$T] ($B): $M", :time_format => "%d/%b/%Y"
# 
# Loggers can also take a proc with a single argument as an output:
#  setup_logger proc{|msg| puts "From Proc: " + msg}
#    #=> <WhinerTools::Logger:0x12a39a0 @targets=[#<WhinerTools::Logger::Target:0x12a393c @out=#<Proc:0x4ce678>, @log_level=0>]>
#  logger.warn "This is a warning!"
#    #=> From Proc: WARN [03/Aug/2009:10:57:27 -0700] ((irb):3:in `irb_binding'): This is a warning!
def setup_logger(out=nil, options={}, &block)
  out = $stdout unless out || block_given?
  @logger = WhinerTools::Logger.new(out, options, &block)
end


# Calls the logger defined by 'setup_logger'. If 'setup_logger' was not called,
# returns a new default logger with a single $stdout output target.
# "debug", "info", "warn", "error", "fatal" are valid log methods.
#  logger.warn "This is a warning!"
#    #=> WARN [03/Aug/2009:10:15:10 -0700] ((irb):46:in `irb_binding'): This is a warning!
def logger
  @logger ||= WhinerTools::Logger.new($stdout)
end