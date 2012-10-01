require 'server/common_defaults'

module SquirrelDB
  
  module Server

    class ServerDefaults < CommonDefaults
      
      DEFAULT_DH_MODULUS_SIZE = 4096
      DEFAULT_PUBLIC_KEY_FILE_NAME = Pathname.new('server.pub')
      DEFAULT_PRIVATE_KEY_FILE_NAME = Pathname.new('server.priv')
      DEFAULT_DATABASE_FILE_NAME = Pathname.new('database.sqrl')
      DEFAULT_LOG_FILE_NAME = Pathname.new('server.log')
      
      def subdirectory
        super + Pathname('server')
      end

      def default_options
        super.merge({
          :dh_modulus_size => DEFAULT_DH_MODULUS_SIZE,
          :public_key_file => config.home.to_path + DEFAULT_PUBLIC_KEY_FILE_NAME,
          :private_key_file => config.home.to_path + DEFAULT_PRIVATE_KEY_FILE_NAME,
          :database_file => data.home.to_path + DEFAULT_DATABASE_FILE_NAME,
          :log_file => data.home.to_path + DEFAULT_LOG_FILE_NAME
        })
      end
            
    end
    
  end
  
end
