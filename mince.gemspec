# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'mince/version'

Gem::Specification.new do |s|
  s.name        = "mince"
  s.version     = Mince::VERSION
  s.authors     = ["Matt Simpson", "Jason Mayer", "Asynchrony Solutions"]
  s.email       = ["matt@railsgrammer.com", "jason.mayer@gmail.com"]
  s.homepage    = "https://github.com/asynchrony/mince"
  s.summary     = %q{Lightweight MongoDB ORM for Ruby.}
  s.description = %q{Lightweight MongoDB ORM for Ruby.}

  s.rubyforge_project = "mince"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('activesupport', '~> 3.0')
  s.add_dependency('mongo', '~> 1.5.2')
  s.add_dependency('bson_ext', '~> 1.5.2')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
end
