require 'ast/common/element'

module SquirrelDB

  module AST

    class UnaryOperation < Element

      def initialize(operator, inner)
        @operator = operator
        @inner = inner
      end

      attr_reader :operator, :inner

      def type
        @inner.type
      end
      
      def to_s
        "(" + @operator.to_s + @inner.to_s + ")"
      end

      def inspect
        "(" + @operator.to_s + @inner.inspect + ")"
      end

      def ==(other)
        super && @operator == other.operator && @inner == other.inner
      end
      
      def hash
        @hash ||= [super, @operator, @inner].hash
      end

    end

  end

end
