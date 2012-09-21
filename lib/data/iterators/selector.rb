require 'data/iterators/rel_alg_iterator'

module SquirrelDB

  module Data
  
    class Selector < RelAlgIterator
  
      def initialize( expression, inner, evaluator )
        super()
        @expression = expression
        @inner = inner
        @evaluator = evaluator
      end
  
      def_delegators :@inner, :open, :close, :rewind, :size
  
      def next_item
        super
        while (t = @inner.next_item)
          return t if @expression.evaluate( TupleState.new( @state, t ) )
        end
        nil
      end
      
      def rewind
        @inner.rewind
      end
      
      def cost
        @cost ||= @inner.cost * @expression.cost
      end
  
    end
  
  end

end
