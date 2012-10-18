Gem::Specification.new do |s|
  s.name        = 'SquirrelDB'
  s.version     = '0.0.0.pre'
  s.date        = '2012-10-18'
  s.summary     = "A small and incomplete SQL database in pure Ruby."
  s.authors     = "Bernhard Brodowsky"
  s.email       = 'brodowsb@ethz.ch'
  s.bindir      = 'bin'
  s.license     = 'GPLv3'
  s.executables = ['client', 'server']
  s.files       = Dir['lib/**/*.rb', 'bin/*.rb', 'spec/**/*.rb', 'Rakefile']
  s.homepage    = 'https://github.com/Lykos/SquirrelDB'
  s.required_ruby_version = '>= 1.9.2'
  s.test_files  = Dir['spec/**/*_spec.rb']
  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'xdg'
  s.add_runtime_dependency 'eventmachine'
  s.add_runtime_dependency 'rspec'
  s.add_runtime_dependency 'racc'
  s.add_runtime_dependency 'json'
end
