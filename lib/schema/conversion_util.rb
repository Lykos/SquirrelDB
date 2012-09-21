require 'storage/raw_util'
require 'schema/type'

module SquirrelDB
  
  module Schema

    module ConversionUtil

      # Size of long integers (which are short compared to ruby integers)
      SHORT_SIZE = 8
      
      include Storage::RawUtil

      # Converts a rawstring which is interpreted as type to a field and returns
      # the result and the remaining raw string.
      #
      def raw_to_field( raw_string, type )
        case type
        when Type::SHORT
          [extract_int( raw_string[0...SHORT_SIZE] ), raw_string[SHORT_SIZE..-1]]
        else
          raise "Type #{type} not supported."
        end
      end

      def field_to_raw( field, type )
       case type
        when Type::SHORT
          encode_int( field, SHORT_SIZE )
        else
          raise "Type #{type} not supported."
        end
      end

    end
      
  end

end
