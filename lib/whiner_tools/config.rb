module WhinerTools
  
  class Config
    
    DEFAULT_COLORS = {:todos => :cyan, :deprecation => :yellow}
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
      @options = {
        :inline_warnings => false,
        :compact_warnings => true,
        :full_backtrace => false,
        :color => DEFAULT_COLORS,
        :output => ShellOutput.new(DEFAULT_COLORS)
      }
    end
    
  end
  
end