require 'ast/iterators/rel_alg_iterator'

module SquirrelDB

  module AST
  
    class Selector < RelAlgIterator
  
      def initialize( expression, inner )
        super()
        @expression = expression
        @inner = inner
      end
  
      def_delegators :@inner, :itopen, :close, :rewind, :size
  
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
      
      def accept(visitor)
        let_visit( visitor, @expression.accept(visitor), @inner.accept(visitor) )
      end
  
    end
  
  end

end
