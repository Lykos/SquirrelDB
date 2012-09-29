require 'storage/raw_util'
require 'schema/type'

module SquirrelDB
  
  module Schema

    module ConversionUtil

      # Size of long integers (which are short compared to ruby integers) Note that the highest one is the sign/null byte
      SHORT_SIZE = 8
      NULL_INDICATOR = 0xFF.chr
      NON_NULL = 0.chr # Other values also indicate non-null values, but this is the default
      SIGN_POSITIVE = 0.chr
      SIGN_NEGATIVE = 1.chr
      BOOLEAN_TRUE = 1.chr
      BOOLEAN_FALSE = 0.chr

      include Storage::RawUtil
            
      # TODO Better introduce classes for all types

      # Converts a raw string which is interpreted as type to a field and returns
      # the result and the remaining. The used part of the raw string is cut off.
      #
      def raw_to_field(raw_string, type)
        null_indicator = raw_string.slice!(0)
        return nil if null_indicator == NULL_INDICATOR
        case type
        when Type::SHORT
          sign = if null_indicator == SIGN_POSITIVE
            1
          elsif null_indicator == SIGN_NEGATIVE
            0
          else
            raise "Invalid sign encoding #{extract_int(null_indicator)}."
          end
          sign * extract_int(raw_string.slice!(0...SHORT_SIZE))
        when Type::BOOLEAN
          if null_indicator == BOOLEAN_POSITIVE
            true
          elsif null_indicator == BOOLEAN_NEGATIVE
            false
          else
            raise "Invalid encoding of a boolean #{extract_int(null_indicator)}."
          end
        when Type::STRING
          length = extract_int(raw_string.slice!(0...SHORT_SIZE))
          raw_string.slice!(0...length).force_encoding(Encoding::UTF_8)
        else
          raise "Type #{type} not supported."
        end
      end

      def field_to_raw(field, type)
        if field.nil?
          return NULL_INDICATOR
        end
        case type
        when Type::SHORT
          (field >= 0 ? SIGN_POSITIVE : SIGN_NEGATIVE) + encode_int(field, SHORT_SIZE)
        when Type::BOOLEAN
          field ? BOOLEAN_TRUE : BOOLEAN_FALSE
        when Type::STRING
          NON_NULL + encode_int(field.length, SHORT_SIZE) + field
        else
          raise "Type #{type} not supported."
        end
      end

    end
      
  end

end
