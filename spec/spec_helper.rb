if self.class.const_defined?(:EY_ROOT)
  raise "don't require the spec helper twice!"
end

EY_ROOT = File.expand_path("../..", __FILE__)
require 'rubygems'
require 'bundler/setup'
# Engineyard gem
$LOAD_PATH.unshift(File.join(EY_ROOT, "lib"))
require 'ey_config'

# Spec stuff
require 'rspec'
require 'yaml'
require 'awesome_print'
require 'pry'

EY::Config.class_eval do
  class << self
    def warn(arg)
      warnings << arg
    end
    def warnings
      @warnings ||= []
    end
    def reset!
      @config = nil
    end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    EY::Config.warnings.clear
    EY::Config.reset!
  end
end
