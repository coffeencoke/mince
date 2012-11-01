# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'mince/version'

Gem::Specification.new do |s|
  s.name        = "mince"
  s.version     = Mince.version
  s.authors     = ["Matt Simpson", "Asynchrony"]
  s.email       = ["matt@railsgrammer.com"]
  s.homepage    = "https://github.com/coffeencoke/#{s.name}"
  s.summary     = %q{Library to interact with mince interfacing data libraries}
  s.description = %q{Library to interact with mince interfacing data libraries}

  s.rubyforge_project = s.name
  s.has_rdoc = true

  s.files         = %w(
    lib/mince.rb 
    lib/mince/version.rb 
    lib/mince/config.rb 
    lib/mince/data_model.rb
    lib/mince/model.rb
    lib/mince/shared_examples/interface_example.rb
  )

  s.test_files    = %w(
    spec/units/mince/config_spec.rb 
    spec/units/mince/interface_example_spec.rb
    spec/units/mince/data_model_spec.rb
    spec/units/mince/model_spec.rb
    spec/integration/simple_mince_data_model_spec.rb
  )
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '~> 3.0'
  s.add_dependency 'activemodel', '~> 3.0'

  s.required_ruby_version = '~> 1.9.0'

  s.add_development_dependency('rake', '~> 0.9')
  s.add_development_dependency('rspec', '~> 2.0')
  s.add_development_dependency('guard-rspec', '~> 0.6')
  s.add_development_dependency "yard", "~> 0.7"
  s.add_development_dependency "redcarpet", "~> 2.1"
  s.add_development_dependency "debugger", "~> 1.2"
  s.add_development_dependency "hashy_db", "2.0.0.pre"
  s.add_development_dependency "rb-fsevent", "~> 0.9.0"
end
