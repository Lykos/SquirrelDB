require 'server/common_defaults'

module SquirrelDB
  
  module Server

    class ServerDefaults < CommonDefaults
      
      DEFAULT_DH_MODULUS_SIZE = 4096
      DEFAULT_PUBLIC_KEY_FILE_NAME = Pathname.new('server.pub')
      DEFAULT_PRIVATE_KEY_FILE_NAME = Pathname.new('server.priv')
      
      def subdirectory
        super + Pathname('server')
      end

      def default_options
        super.merge({
          :dh_modulus_size => DEFAULT_DH_MODULUS_SIZE,
          :public_key_file => config.home + DEFAULT_PUBLIC_KEY_FILE_NAME,
          :private_key_file => config.home + DEFAULT_PRIVATE_KEY_FILE_NAME
        })
      end
            
    end
    
  end
  
end
