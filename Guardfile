group :integration do
  guard 'rspec', :version => 2, spec_paths: ["spec/integration"] do
    watch('Gemfile') { "spec/integration" }
    watch('Gemfile.lock') { "spec/integration" }
    watch('mince.gemspec') { "spec/integration" }
    watch(%r{^spec/integration/.+_spec\.rb$}) 
    watch(%r{^lib/(.+)\.rb$}) { "spec/integration" }
    watch(%r{^lib/mince/(.+)\.rb$}) { "spec/integration" }
  end
end

group :units do
  guard 'rspec', :all_after_pass => false, :version => 2, spec_paths: ["spec/units/mince"] do
    watch(%r{^spec/support/shared_examples/(.+)$}) { "spec/units" }
    watch('Gemfile') { "spec/units" }
    watch('Gemfile.lock') { "spec/units" }
    watch('mince.gemspec') { "spec/units" }
    watch(%r{^spec/units/mince/.+_spec\.rb$})
    watch(%r{^lib/mince/(.+)\.rb})                { |m| "spec/units/mince/#{m[1]}_spec.rb" }
  end
end
