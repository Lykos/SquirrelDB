require 'rubygems'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'rspec_encoding_matchers'

RSpec::Core::RakeTask.new do |t|
  t.fail_on_error = false
end

Rake::RDocTask.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "doc"
end
