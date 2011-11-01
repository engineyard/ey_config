require 'bundler'
Bundler.require

puts EY::Config.get(:foo_service, :api_key)