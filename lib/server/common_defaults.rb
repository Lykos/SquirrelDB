gem xdg
require 'xdg'

module SquirrelDB
  
  module Server

    class CommonDefaults
      
      include XDG::BaseDir::Mixin
      
      DEFAULT_CONFIG_FILE_NAME = Pathname.new('config.yml')
            
      def default_options
        {
          :config_file => config.home.path + DEFAULT_CONFIG_FILE_NAME,
          :port => DEFAULT_PORT,
        }
      end
      
      def subdirectory
        Pathname('squirreldb')
      end
      
      def config_files
        [config.dirs, config.home].flat_map do |base_dirs|
          base_dirs.paths.map { |p| p + DEFAULT_CONFIG_FILE }
        end
      end
            
    end
    
  end
  
end