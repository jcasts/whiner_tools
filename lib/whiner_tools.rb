# ruby ~ whiner_tools.rb

# TODO: settings loading - read whiner.opts
#       need to be able to specify an output method
module WhinerTools
  VERSION = "0.0.2" unless defined?(VERSION)
  
  @@config = nil
  @@print_cache = Hash.new {|hash, key| hash[key] = []}
  
  def self.print(print_hash, options={})
    print_hash = {"Uncategorized" => print_hash.to_s} unless print_hash.is_a?(Hash)
    backtrace = config.backtrace || options[:backtrace]
    
    print_hash.each do |title, value|
      if options[:inline] || config.inline_warnings
        config.output.render :oneline => "#{title}: #{value}", :format => title.downcase.to_sym
      else
        if backtrace
          range = case backtrace
          when Range then backtrace
          when Integer then [1..backtrace]
          when TrueClass then [1..-1]
          end
          value = "#{value}\n  #{caller[range].join("\n  ")}"
        end
        @@print_cache[title] << value
      end
    end
  end
  
  def self.output(label=nil)
    # TODO: group exact same entries and put "(called X times)" unless compact_warnings option is false
    to_render = label ? {label => @@print_cache[label]} : @@print_cache
    to_render.each do |title, values|
      config.output.render :header => title,
                           :body   => values.join("\n"),
                           :format => title.downcase.to_sym
    end
    @@print_cache.clear
  end
  
  # Used to configue and start WhinerTools. Takes a block to define configuration.
  #  WhinerTools.setup do
  #    self.backtrace = [0..2]
  #    self.color[:vacuums] = :red
  #  end
  def self.setup(&block)
    config.instance_eval(&block) if block_given?
  end
  
  # Returns the config object.
  def self.config
    @@config ||= Config.new
  end
  
end

require 'yaml'

%w[shell_output config logger global].each do |filename|
  require "#{File.dirname(__FILE__)}/whiner_tools/#{filename}"
end
