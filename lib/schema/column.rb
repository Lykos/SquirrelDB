require 'schema/type'
require 'schema/conversion_util'

module RubyDB

  module Schema

    class Column

      def initialize( name, type )
        @name = name
        @type = type
      end

      include ConversionUtil

      attr_reader :name, :type

      def to_field( raw_string )
        raw_to_field( raw_string, @type )
      end

      def to_raw( value )
        field_to_raw( value, @type )
      end

    end

  end
  
end
