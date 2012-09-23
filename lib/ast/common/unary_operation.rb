require 'ast/common/element'

module SquirrelDB

  module AST

    class UnaryOperation < Element

      def initialize( operator, inner )
        @operator = operator
        @inner = inner
      end

      attr_reader :operator, :inner

      def to_s
        "(" + @operator.to_s + @inner.to_s + ")"
      end

      def inspect
        "(" + @operator.to_s + @inner.inspect + ")"
      end

      def ==(other)
        super && @operator == other.operator && @inner == other.inner
      end

      def accept( visitor )
        let_visit( visitor, @operator, @inner.accept( visitor ) )
      end

      def evaluate( state )
        case operator
        when UNARY_PLUS then @inner.evaluate( state )
        when UNARY_MINUS then -@inner.evaluate( state )
        when NOT then @inner.evaluate( state )
        else
          raise
        end
      end

    end

  end

end
