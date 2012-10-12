require 'server/common_defaults'
require 'pathname'

module SquirrelDB
  
  module Client

    class ClientDefaults < Server::CommonDefaults
      
      DEFAULT_PUBLIC_KEYS_FILE_NAME = Pathname.new('public_keys.yml')
      
      def subdirectory
        super + Pathname.new('client')
      end
      
      def default_options
        super.merge({
          :public_keys_file => config.home.to_path + DEFAULT_PUBLIC_KEYS_FILE_NAME,
          :aliases => {}
        })
      end
      
    end
    
  end
  
end
