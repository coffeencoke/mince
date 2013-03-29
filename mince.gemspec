# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'mince/version'

Gem::Specification.new do |s|
  s.name        = "mince"
  s.version     = Mince.version
  s.authors     = ["Matt Simpson", "Asynchrony"]
  s.email       = ["matt@railsgrammer.com"]
  s.homepage    = "https://github.com/coffeencoke/#{s.name}"
  s.summary     = %q{Ruby library to provide a light weight flexible ORM}
  s.description = %q{Library to interact with databases, not tied to rails, and not tied to active record pattern}

  s.rubyforge_project = s.name
  s.has_rdoc = true
  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE.txt README.md)
  s.test_files = Dir.glob('spec/**/*.rb')
  s.license = "MIT"
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '~> 3.0'
  s.add_dependency 'activemodel', '~> 3.0'

  s.required_ruby_version = '>= 1.9.3'

  s.add_development_dependency('rake', '~> 0.9')
  s.add_development_dependency('rspec', '~> 2.0')
  s.add_development_dependency('guard-rspec', '~> 0.6')
  s.add_development_dependency "yard", "~> 0.7"
  s.add_development_dependency "redcarpet", "~> 2.1"
  s.add_development_dependency "debugger", "~> 1.2"
  s.add_development_dependency "hashy_db", "~> 2.0"
  s.add_development_dependency "rb-fsevent", "~> 0.9.0"
end
