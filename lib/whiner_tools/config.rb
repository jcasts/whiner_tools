module WhinerTools
  
  # Configuration class initialized by first whiner call or by
  # WhinerTools.setup.
  class Config
    
    CONFIG_FILEPATH = "#{Dir.getwd}/whiner.opts"
    
    COLOR_SETUP = {:todos => :cyan, :deprecation => :yellow}
    
    DEFAULT_OPTIONS = {
      :inline_warnings => false,
      :compact_warnings => true,
      :backtrace => false,
      :color => COLOR_SETUP.dup,
      :output => nil
    }
    
    ATTRIBUTES = [:inline_warnings, :compact_warnings, :full_backtrace, :color, :output]
    
    ATTRIBUTES.each do |attrib|
      class_eval <<-END
      def #{attrib}
        @options[#{attrib.inspect}]
      end
      def #{attrib}=(value)
        @options[#{attrib.inspect}] = value
      end
      END
    end
    
    def initialize
      @options = DEFAULT_OPTIONS.dup
      file_config = load_file(CONFIG_FILEPATH)
      self.color.merge!(file_config.delete(:color) || {})
      self.output = ShellOutput.new(self.color)
      @options.merge(file_config)
    end
    
    # Load a yaml config file. Yaml parsing should return a Hash.
    def load_file(filepath)
      parsed_yaml = ( YAML.load_file(filepath) if File.file?(filepath) )
      parsed_yaml.is_a?(Hash) ? parsed_yaml : {}
    end
    
  end
  
end