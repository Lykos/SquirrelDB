require 'ast/type'

module SquirrelDB

  module Sql

    class Conversion

      def initialize( from_type, to_type, &function )
        @function = function
        @from_type = from_type
        @to_type = to_type
      end

      attr_reader :function, :from_type, :to_type

      def convert( from_value )
        raise unless from_value.type == @from_type
        to_value = function.call( from_value )
        raise unless to_value.type == @to_type
        to_value
      end

      Conversions = [
        Conversion.new( Type::INTEGER, Type::DOUBLE ) { |i| i.to_f },
        Conversion.new( Type::DOUBLE, Type::INTEGER ) { |d| d.to_i },
      ]

      def self.from( from_type )
        Conversions.select { |t| t.from_type == from_type }
      end

      def self.to( to_type )
        Conversions.select { |t| t.to_type == to_type }
      end
      
    end

  end

end
