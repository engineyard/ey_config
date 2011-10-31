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


