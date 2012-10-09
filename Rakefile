require 'rubygems'
require 'rdoc/task'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.ruby_opts = ['-rtest/unit']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Rake::RDocTask.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
end
