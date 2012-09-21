require 'sql/elements/syntactic_unit'

module SquirrelDB

  module Sql

    class Constant < SyntacticUnit

      def initialize( value, type )
        @value = value
        @type = type
      end

      attr_reader :value, :type

      def to_s
        @value.to_s
      end

      def inspect
        @value.to_s + "::" + @type.to_s
      end

      def ==(other)
        super && @type == other.type && @value == other.value
      end

      def accept( visitor )
        let_visit( visitor, @value, @type )
      end

      def evaluate( state )
        @value
      end

    end

  end

end
