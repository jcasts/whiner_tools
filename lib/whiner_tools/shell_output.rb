module WhinerTools
  
  class ShellOutput
    
    IO_OUT = $stdout
    
    COLORS = {
      :black    => ["30", "40"],
      :red      => ["31", "41"],
      :green    => ["32", "42"],
      :yellow   => ["33", "43"],
      :blue     => ["34", "44"],
      :violet   => ["35", "45"],
      :cyan     => ["36", "46"],
      :white    => ["37", "47"],
      :default  => ["00", "00"]
    }
    
    
    def initialize(colors=nil)
      @colors = colors
    end
    
    def print(print_hash, flush=false)
      render!(print_hash) and return if flush
      
      print_hash.each do |key, value|
        @print_cache[key] << value
      end
    end
    
    def render(options={})
      header  = format_string(" == #{options[:header]} == ", options[:format], :header) if options[:header]
      oneline = format_string(" #{options[:oneline]} ", options[:format], :oneline) if options[:oneline]
      body    = format_string(options[:body],   options[:format], :body) if options[:body]
      
      IO_OUT.print `echo "\n#{[header, oneline, body].compact.join('\n')}\\c"`, "\n"
      IO_OUT.flush
    end
    
    
    
    private
    

    def format_string(string, format, content_type)
      return nil unless string
      format_color(format, content_type) + string + get_color(:default)
    end
    
    def format_color(format_name, content_type)
      return "" unless @colors
      return get_color(@colors[format_name], content_type != :body)
    end
    
    def get_color(color_name, bg=false)
      return "" unless COLORS[color_name]
      if bg
        fcolor = COLORS[:black][0] + ';'
        bcolor = COLORS[color_name][1]
      else
        fcolor = COLORS[color_name][0]
        bcolor = ""
      end
      return ansi_escape('\\033['+fcolor+bcolor+'m')
    end
    
    def ansi_escape(string)
      return string
      #'\['+string+'\]'
    end
    
  end
  
end