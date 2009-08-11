module WhinerTools
  
  class Config
    
    COLOR_SETUP = {:todos => :cyan, :deprecation => :yellow}
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
        :color => COLOR_SETUP,
        :output => ShellOutput.new(COLOR_SETUP) # Referencing the same object as :color makes the output color swappable on the fly
      }
    end
    
  end
  
end