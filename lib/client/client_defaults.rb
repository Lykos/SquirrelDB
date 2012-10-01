require 'server/common_defaults'

module SquirrelDB
  
  module Client

    class ServerDefaults < Server::CommonDefaults
      
      DEFAULT_PUBLIC_KEYS_FILE = 'public_keys.yml'
      
      def subdirectory
        super + Pathname('client')
      end
      
      def default_options
        super.merge({
          :public_keys_file => DEFAULT_PUBLIC_KEY_FILE
        })
      end
      
    end
    
  end
  
end
