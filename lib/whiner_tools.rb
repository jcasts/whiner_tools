# ruby ~ whiner_tools.rb

# TODO: settings loading - read whiner.opts
#       need to be able to specify an output method
module WhinerTools
  VERSION = "0.0.2" unless defined?(VERSION)
  
  @@config = nil
  @@print_cache = Hash.new {|hash, key| hash[key] = []}
  
  def self.print(print_hash, flush=false)
    print_hash = {"Uncategorized" => print_hash.to_s} unless print_hash.is_a?(Hash)
    
    print_hash.each do |title, value|
      if flush || @@config.inline_warnings
        @@config.output.render :header => "#{title}: #{value}", :format => title.downcase.to_sym
      else
        @@print_cache[title] << value
      end
    end
  end
  
  def self.output(label=nil)
    # TODO: group exact same entries and put "(called X times)" unless compact_warnings option is false
    to_render = label ? {label => @@print_cache[label]} : @@print_cache
    to_render.each do |title, values|
      @@config.output.render :header => title,
                             :body   => values.join("\n"),
                             :format => title.downcase.to_sym
    end
    @@print_cache.clear
  end
  
  # Used to configue and start WhinerTools
  def self.start(&block)
    @@config = Config.new
    @@config.instance_eval(&block) if block_given?
  end
  
end

require 'yaml'

%w[shell_output config logger global].each do |filename|
  require "#{File.dirname(__FILE__)}/whiner_tools/#{filename}"
end

# WhinerTools.start do
#   self.color[:vacuums] = :red
# end
WhinerTools.start

TODO "first todo test"
TODO "second todo test"
deprecated :use => "new_method"
deprecated :message => "muahahaha"

whine :about => "Deprecation", :say => "this is a test"
whine :about => "TODOs", :say => "this is another test"

whine :about => "Vacuums", :say => "they suck!", :inline => true
whine :about => "Vacuums", :say => "are they a necessary evil?"

WhinerTools.output