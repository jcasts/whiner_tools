module WhinerTools
  
  # Creates new Logger instances with any number of output targets. Each output target may have a different log level.
  # Log methods available are: "debug", "info", "warn", "error", "fatal" with respective indecies of 0 to 4.
  #  logger.warn "This is a warning!"
  #    #=> WARN [03/Aug/2009:10:15:10 -0700] ((irb):46:in `irb_binding'): This is a warning!
  # 
  # Loggers are typically instantiated with an IO instance target output:
  #  Logger.new $stdout
  #  Logger.new File.open('log_file.txt')
  # 
  # Log level can be passed to the options argument and is typically an index between 0 and 4. The default log level is 0 (debug).
  #  Logger.new $stdout, :level => 1
  # Other valid options are :format to define the log format (see format instance method) and :time_format.
  # 
  # Loggers can also take a proc with a single argument as an output:
  #  logger = Logger.new(proc{|msg| puts "From Proc: " + msg})
  #    #=> <WhinerTools::Logger:0x12a39a0 @targets=[#<WhinerTools::Logger::Target:0x12a393c @out=#<Proc:0x4ce678>, @log_level=0>]>
  #  logger.warn "This is a warning!"
  #    #=> From Proc: WARN [03/Aug/2009:10:57:27 -0700] ((irb):3:in `irb_binding'): This is a warning!
  class Logger
    
    LOG_LEVELS = ["debug", "info", "warn", "error", "fatal"]
    
    attr_reader :targets
    
    def initialize(out=nil, options={}, &block)
      @default_options = {:format => "$L [$T] ($B): $M", :time_format => "%d/%b/%Y:%H:%M:%S %z", :level => 0}
      @targets = []
      add_target(out, options) unless !out && block_given?
      yield(self) if block_given?
      raise "A logger must be instantiated with at least one output target but none were defined." if @targets.empty?
    end
    
    # Adds an output target to the logger instance.
    #  logger.add_target File.open('log_file.txt'), :level => 2
    def add_target(out, options={})
      target = Target.new(out, @default_options.merge(options))
      @targets << target
    end
    
    # Sets the output format on all output targets and future default log format. Use $L, $T, $B, $M to define respectively
    # Log level, Time, Backtrace, and Message.
    #  logger.format = "$L [$T]: $M (backtrace: $B)"
    #  logger.warn "This is a warning!"
    #    #=> WARN [03/Aug/2009:10:15:10 -0700]: This is a warning! (backtrace: (irb):46:in `irb_binding')
    def format=(string_format)
      @targets.each{|t| t.format = string_format }
      @default_options[:format] = string_format
    end
    
    # Sets the output time format on all output targets and future default time format. Follows the strftime format.
    def time_format=(string_format)
      @targets.each{|t| t.time_format = string_format }
      @default_options[:time_format] = string_format
    end
    
    # Sets the log level on all output targets and future default log level. lvl must be a positive integer.
    def log_level=(lvl)
      @targets.each{|t| t.log_level = lvl }
      @default_options[:log_level] = lvl
    end
    
    LOG_LEVELS.each_with_index do |level, index|
      class_eval <<-END, __FILE__, __LINE__
        def #{level}(message = nil)
          @targets.each do |t|
            t.log_message("#{level}", message) if t.log_level <= #{index}
          end
          return nil
        end
      END
    end
    
    private
    
    
    class Target
      
      attr_reader :log_level, :out
      attr_accessor :format, :time_format
      
      def initialize(out, options={})
        raise "Target output must be an IO or Proc object. Got: #{out.class}" unless out.is_a?(IO) || out.is_a?(Proc)
        @out = out
        self.log_level = options[:level] || 0
        self.format = options[:format] || "$L [$T] ($B): $M"
        self.time_format = options[:time_format] || "%d/%b/%Y:%H:%M:%S %z"
      end
      
      # Sets the log level of the output target.
      def log_level=(lvl)
        raise "log_level must be an integer between 0 and #{LOG_LEVELS.length - 1}" unless lvl.is_a?(Integer) && lvl < LOG_LEVELS.length
        @log_level = lvl
      end
      
      # Write any log message.
      def log_message(lvl_name, message)
        str = self.format.dup
        str.gsub!(/\$L/, lvl_name.upcase)
        str.gsub!(/\$T/, time_string)
        str.gsub!(/\$B/, caller[3])
        str.gsub!(/\$M/, message.to_s)
        output_message str
      end
      
      private
      
      def time_string
        Time.now.strftime(@time_format)
      end
      
      def output_message(*strings)
        strings << "\n"
        if @out.is_a?(Proc)
          @out.call(strings.join)
        else
          @out.print *strings
          @out.flush
        end
      end
      
    end
    
  end
  
end