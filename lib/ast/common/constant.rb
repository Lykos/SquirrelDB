require 'ast/common/element'

module SquirrelDB

  module AST

    class Constant < Element

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

      def evaluate( state )
        @value
      end

    end

  end

end
