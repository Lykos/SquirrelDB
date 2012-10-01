gem 'xdg'
require 'pathname'
require 'xdg'

module SquirrelDB
  
  module Server

    # A class that provides access to default configs shared between client and server 
    class CommonDefaults
      
      include XDG::BaseDir::Mixin
      
      DEFAULT_PORT = 52324
      DEFAULT_CONFIG_FILE_NAME = Pathname.new('config.yml')
            
      def default_options
        {
          :config_file => user_config_file,
          :port => DEFAULT_PORT,
        }
      end
      
      def user_config_file
        config.home.to_path + DEFAULT_CONFIG_FILE_NAME
      end
      
      def subdirectory
        Pathname('squirreldb')
      end
      
      def config_files
        [config.dirs, config.home].flat_map do |base_dirs|
          base_dirs.paths.map { |p| p + DEFAULT_CONFIG_FILE_NAME }
        end
      end
            
    end
    
  end
  
end