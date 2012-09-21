module RubyDB

  module Data

    # An evaluator for a select in an expression that should return exactly one tuple
    #
    class ValueSelectEvaluator

      def initialize( inner )
        @inner = inner
      end
      
      def cost
        @inner.cost
      end
      
      def size
        @inner.size
      end
      
      def evaluate
        @inner.rewind
        t = @inner.next
        raise if t.nil? || @inner.next
      end
      
    end

  end

end
