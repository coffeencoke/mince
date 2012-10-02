guard 'rspec', :all_after_pass => false, :version => 2, spec_paths: ["spec/units/mince"] do
  watch('Gemfile') { "spec/units" }
  watch('Gemfile.lock') { "spec/units" }
  watch('mince.gemspec') { "spec/units" }
  watch(%r{^spec/units/mince/.+_spec\.rb$})
  watch(%r{^lib/mince/(.+)\.rb})                            { |m| "spec/units/mince/#{m[1]}_spec.rb" }
end
