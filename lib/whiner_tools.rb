# ruby ~ whiner_tools.rb

require File.dirname(__FILE__)+'/whiner_tools/shell_output'


module WhinerTools
  VERSION = "0.0.2" unless defined?(VERSION)
  
  @@options = {:inline_warnings => false, :color => {:todos => :cyan, :deprecation => :yellow} }
  @@output = ShellOutput.new(@@options[:color])
  @@print_cache = Hash.new {|hash, key| hash[key] = []}
  
  def self.print(print_hash, flush=false)
    print_hash = {"Uncategorized" => print_hash.to_s} unless print_hash.is_a?(Hash)
    
    print_hash.each do |title, value|
      if flush || @@options[:inline_warnings]
        @@output.render :header => "[#{title}]: #{value}", :format => title.downcase.to_sym
      else
        @@print_cache[title] << value
      end
    end
  end
  
  def self.output(label=nil)
    # TODO: group exact same entries and put "(called X times)"
    to_render = label ? {label => @@print_cache[label]} : @@print_cache
    to_render.each do |title, values|
      @@output.render :header => title,
                      :body   => values.join("\n"),
                      :format => title.downcase.to_sym
    end
    @@print_cache.clear
  end
  
end


require File.dirname(__FILE__)+'/whiner_tools/logger'
require File.dirname(__FILE__)+'/whiner_tools/global'


TODO "first todo test"
TODO "second todo test"
deprecated :use => "new_method"
deprecated :message => "muahahaha"

WhinerTools.print({"Deprecation" => "this is a test"}, true)
WhinerTools.print({"TODOs" => "this is a test"}, true)
# 
# 
# WhinerTools.print({"Deprecated" => "this is a test"})
# WhinerTools.print({"TODO" => "this is a test"})
# WhinerTools.print({"Deprecated" => "this is another test"})
# WhinerTools.print({"TODO" => "this is another test"})

WhinerTools.output