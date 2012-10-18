require 'rubygems'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'rspec_encoding_matchers'
require 'rake/clean'
$:.unshift('./lib')
require 'server/server_defaults'
require 'client/client_defaults'

CLOBBER.include("lib/sql/ast_parser.tab.rb")

file "lib/sql/ast_parser.tab.rb" => "lib/sql/ast_parser.y" do |t|
  sh "racc -tv lib/sql/ast_parser.y"
end

task :racc => "lib/sql/ast_parser.tab.rb"

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