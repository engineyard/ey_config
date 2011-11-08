# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ey_config/version"

Gem::Specification.new do |s|
  s.name = 'ey_config'
  s.version = EY::Config::VERSION
  s.summary = 'Engine Yard Configuration'
  s.description = 'Access to additional services for Engine Yard customers.'
  s.authors     = ["Jacob Burkhart & Michael Broadhead & others"]
  s.email       = ["jacob@engineyard.com"]
  s.files = Dir.glob("lib/**/*") + %w(LICENSE README.md) 
  s.homepage = 'http://github.com/engineyard/ey_config'
end

