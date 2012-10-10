module SquirrelDB
  
  module Client
    
    class KeyValidator
      
      # Validate a key for a host given the known keys. This returns +:unknown+ if no key is known for this host,
      # +:valid+ if the key is valid and +:invalid+ if a different key is stored for this host.
      # +host+:: Host for which this key is returned.
      # +key+:: A string that represents the key in hexadecimal format.
      def validate_key(host, key)
        if !@public_keys.has_key?(host)
          :unknown
        elsif @public_keys[host] == key
          :valid
        else
          :invalid
        end
      end
      
      # Stores +key+ as the key for +host+ and saves it into the file.
      def accept(host, key)
        @public_keys[host] = key
        File.open(@public_keys_file, 'w') do |f|
          YAML::dump(@public_keys, f)
        end        
      end
      
      protected
      
      # +config+:: A hash table that contains at least the key +:public_keys_file+.
      def initialize(config)
        @public_keys_file = config[:public_keys_file]
        @public_keys = @public_keys_file.exist? ? YAML::load(@public_keys_file.read) : {}
      end
      
    end
  
  end

end