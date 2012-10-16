require 'schema/expression_type'
require 'errors/internal_error'
require 'errors/storage_error'
require 'errors/encoding_error'
require 'storage/raw_util'

module SquirrelDB

  module Schema

    # Represents one type of value that can be stored in the database. 
    class StorageType
      
      TYPES = []
      
      private

      include Storage::RawUtil

      # Size of long integers (which are short compared to ruby integers) Note that the highest one is the sign/null byte
      SHORT_BYTES = 8
      DOUBLE_BYTES = 8
      STRING_LENGTH_BYTES = 2
      INTEGER_LENGTH_BYTES = 2
      NULL_INDICATOR = 0xFF.chr.force_encoding(Encoding::BINARY)
      NORMAL_INDICATOR = 0.chr.force_encoding(Encoding::BINARY)
      SIGN_POSITIVE = 0.chr.force_encoding(Encoding::BINARY)
      SIGN_NEGATIVE = 1.chr.force_encoding(Encoding::BINARY)
      BOOLEAN_TRUE = 1.chr.force_encoding(Encoding::BINARY)
      BOOLEAN_FALSE = 0.chr.force_encoding(Encoding::BINARY)
    
      protected
    
      def self.new(*args)
        super
      end
      
      def initialize(name, type_id, expression_type)
        @name = name
        @type_id = type_id
        @expression_type = expression_type
        TYPES << self
      end
      
      public
      
      attr_reader :name, :type_id, :expression_type
      
      INTEGER = StorageType.new("integer", 1, ExpressionType::INTEGER)
      STRING = StorageType.new("string", 2, ExpressionType::STRING)
      BOOLEAN = StorageType.new("boolean", 3, ExpressionType::BOOLEAN)
      DOUBLE = StorageType.new("double", 4, ExpressionType::DOUBLE)
      SHORT = StorageType.new("short", 5, ExpressionType::INTEGER)
      
      def load_variant_indicator(raw)
        raise EncodingError unless raw.encoding == Encoding::BINARY
        raw.slice!(0)
      end
      
      def sign_indicator(variant_indicator)
        case variant_indicator
        when SIGN_POSITIVE then 1
        when SIGN_NEGATIVE then -1
        else
          raise StorageError, "Invalid sign encoding #{variant_indicator.dump}."
        end
      end
      
      def sign_variant(integer)
        (integer >= 0 ? SIGN_POSITIVE : SIGN_NEGATIVE).chr.force_encoding(Encoding::BINARY)
      end
      
      def INTEGER.load(raw)
        variant_indicator = load_variant_indicator(raw)
        return nil if variant_indicator == NULL_INDICATOR
        sign = sign_indicator(variant_indicator)
        length = extract_int(raw.slice!(0, INTEGER_LENGTH_BYTES))
        sign * extract_int(raw.slice!(0, length))
      end
      
      def INTEGER.store(integer)
        return NULL_INDICATOR.dup unless integer
        raw = encode_int(integer.abs)
        sign_variant(integer) + encode_int(raw.length, INTEGER_LENGTH_BYTES) + raw
      end
      
      def BOOLEAN.load(raw)
        variant_indicator = load_variant_indicator(raw)
        return nil if variant_indicator == NULL_INDICATOR
        case variant_indicator
        when BOOLEAN_TRUE then true
        when BOOLEAN_FALSE then false
        else
          raise StorageError, "Invalid encoding of a boolean #{variant_indicator.dump}."
        end
      end
      
      def BOOLEAN.store(boolean)
        return NULL_INDICATOR.dup if boolean.nil?
        (boolean ? BOOLEAN_TRUE : BOOLEAN_FALSE).chr.force_encoding(Encoding::BINARY)
      end
      
      def STRING.load(raw)
        variant_indicator = load_variant_indicator(raw)
        return nil if variant_indicator == NULL_INDICATOR
        raise "Unknown String variant #{variant_indicator.dump}." unless variant_indicator == NORMAL_INDICATOR
        length = extract_int(raw.slice!(0, STRING_LENGTH_BYTES))
        raw.slice!(0, length).force_encoding(Encoding::UTF_8)
      end
      
      def STRING.store(string)
        return NULL_INDICATOR.dup unless string
        NORMAL_INDICATOR.chr.force_encoding(Encoding::BINARY) + encode_int(string.length, STRING_LENGTH_BYTES) + string.force_encoding(Encoding::BINARY)
      end
      
      def SHORT.load(raw)
        variant_indicator = load_variant_indicator(raw)
        return nil if variant_indicator == NULL_INDICATOR
        sign = sign_indicator(variant_indicator)
        sign * extract_int(raw.slice!(0, SHORT_BYTES))
      end
      
      def SHORT.store(integer)
        return NULL_INDICATOR.dup unless integer
        sign_variant(integer) + encode_int(integer.abs, SHORT_BYTES)
      end
      
      def DOUBLE.load(raw)
        variant_indicator = load_variant_indicator(raw)
        return nil if variant_indicator == NULL_INDICATOR
        raise "Unknown Double variant #{variant_indicator}." unless variant_indicator == NORMAL_INDICATOR
        raw.slice!(0, DOUBLE_BYTES).unpack("E")[0]
      end
      
      def DOUBLE.store(double)
        return NULL_INDICATOR.dup unless double
        NORMAL_INDICATOR.chr.force_encoding(Encoding::BINARY) + [double].pack("E").force_encoding(Encoding::BINARY)
      end
    
      # Returns the type with the given id and raises an
      # exception, if no such type exists. 
      def self.by_id(id)
        type = TYPES.find { |t| t.type_id == id }
        raise InternalError, "No type with type id #{id} known." unless type
        type
      end
      
      # Returns the type with the given name and raises an
      # exception, if no such type exists. 
      def self.by_name(name)
        type = TYPES.find { |t| t.name == name }
        raise InternalError, "No type with type name #{name} known." unless type
        type
      end
      
      # Returns true if a type with the given name exists.
      def self.has_name(name)
        TYPES.any? { |t| t.name == name }
      end

      def ==(other)
        self.class == other.class &&
        @name == other.name &&
        @type_id == other.type_id &&
        @expression_type == other.expression_type
      end
      
      def eql?(other)
        self == other
      end
      
      def hash
        @hash ||= [self.class.hash, name].hash
      end

      def to_s
        @name + "_st"
      end

      def inspect
        "StorageType(#{@name}, #{@type_id}, #{@expression_type})"
      end
      
      # Returns a Proc object that converts values of the given type to a value
      # which can be stored into this storage type. 
      # +expression_type+:: The type of the expression to be converted.
      def converts_from?(expression_type)
        expression_type.auto_converts_to?(@expression_type)
      end

      # Returns a Proc object that converts values of the given type to a value
      # which can be stored into this storage type. 
      # +expression_type+:: The type of the expression to be converted.
      def convert_from(expression_type)
        expression_type.auto_conversion_to(@expression_type)
      end

    end

  end
  
end
