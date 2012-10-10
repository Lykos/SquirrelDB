module SquirrelDB
  
  module Client
    
    class KeyValidator
      
      def validate_key(host, key)
        if !@public_keys.has_key?(host)
          :unknown
        elsif @public_keys[host] == key
          :valid
        else
          :invalid
        end
      end

      private
      
      def write_public_keys
        File.open(@config[:public_keys_file], 'w') do |f|
          YAML::dump(@public_keys, f)
        end
      end
      
      protected
      
      # +config+:: A hash table that contains at least the key +:public_keys_file+.
      def initialize(config)
        @config = config
        @public_keys = @config[:public_keys_file].exist? ? YAML::load(@config[:public_keys_file].read) : {}
      end
      
    end
  
  end

end