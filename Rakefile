require 'rubygems'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'rspec_encoding_matchers'
require 'rake/clean'

CLOBBER.include("lib/sql/ast_parser.tab.rb")

file "lib/sql/ast_parser.tab.rb" => ["lib/sql/ast_parser.y"] do |t|
  sh "racc -tv lib/sql/ast_parser.y"
end

task :racc => ["lib/sql/ast_parser.tab.rb"]

RSpec::Core::RakeTask.new(:spec => :racc) do |t|
  t.fail_on_error = false
end

Rake::RDocTask.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_files.exclude("lib/**/*.tab.rb")
  rd.rdoc_dir = "doc"
end
