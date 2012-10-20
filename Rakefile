require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'rspec_encoding_matchers'
require 'rake/clean'

$:.unshift('./lib')
require 'server/server_defaults'
require 'client/client_defaults'

CLOBBER.include("lib/sql/ast_parser.tab.rb")

task :default => :spec

file "lib/sql/ast_parser.tab.rb" => "lib/sql/ast_parser.y" do |t|
  sh "racc -tv lib/sql/ast_parser.y"
end

task :racc => "lib/sql/ast_parser.tab.rb"

spec = Gem::Specification.new do |s|
  s.name        = 'SquirrelDB'
  s.version     = '0.0.0.pre'
  s.date        = '2012-10-18'
  s.platform    = Gem::Platform::RUBY	
  s.summary     = "A small and incomplete SQL database in pure Ruby."
  s.authors     = "Bernhard Brodowsky"
  s.email       = 'brodowsb@ethz.ch'
  s.bindir      = 'bin'
  s.license     = 'GPLv3'
  s.executables = ['client', 'server']
  s.files       = Dir['lib/**/*.rb', 'lib/**/*.y', 'bin/*.rb', 'spec/**/*.rb', 'Rakefile']
  s.homepage    = 'https://github.com/Lykos/SquirrelDB'
  s.required_ruby_version = '>= 1.9.2'
  s.test_files  = Dir['spec/**/*_spec.rb']
  s.add_development_dependency 'rake'
  s.add_runtime_dependency 'xdg'
  s.add_runtime_dependency 'eventmachine'
  s.add_runtime_dependency 'rspec'
  s.add_runtime_dependency 'racc'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'loggin'
  s.post_install_message = 'It worked!'
end

Gem::PackageTask.new(spec).define

RSpec::Core::RakeTask.new(:spec => :racc) do |t|
  t.fail_on_error = false
end

Rake::RDocTask.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_files.exclude("lib/**/*.tab.rb")
  rd.rdoc_dir = "doc"
end

task :client_config do
  ruby 'bin/client -vf --create-config'
end

task :server_config => :racc do
  ruby 'bin/server -vf --create-config'
end

task :genkeys => :racc do
  ruby 'bin/server -vf --generate-keys 4096'
end

task :createdb => :racc do
  ruby 'bin/server -vf --create-database'
end

task :start_server => :racc do
  ruby 'bin/server -v'
end

task :rm_config => [:rm_server_config, :rm_client_config]

task :rm_server_config => :rm_server_keys do
  rm SquirrelDB::Server::ServerDefaults.new.user_config_file
end

task :rm_client_config => :rm_server_keys do
  rm SquirrelDB::Server::ClientDefaults.new.user_config_file
end

task :rm_keys => [:rm_server_keys, :rm_client_keys]

task :rm_server_keys do
  rm SquirrelDB::Server::ServerDefaults.new.default_options[:public_key_file]
  rm SquirrelDB::Server::ServerDefaults.new.default_options[:private_key_file]
end

task :rm_client_keys do
  rm SquirrelDB::Client::ClientDefaults.new.default_options[:public_keys_file]
end
