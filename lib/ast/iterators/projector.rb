require 'forwardable'
require 'ast/iterators/rel_alg_iterator' 

module SquirrelDB

  module AST

    class Projector < RelAlgIterator

      def initialize(column_evaluators, inners)
        @column_evaluators = column_evaluators
        @inner = inner
      end

      def_delegators :@inner, :itopen, :close, :size, :rewind

      def next_item
        super
        t = @inner.next_item
        return nil unless t
        state = TupleState.new( @state, t )
        @column_evaluators.collect do |column_evaluator|
          column_evaluator.evaluate( state )
        end
      end
      
      def rewind
        super
        @inner.rewind
      end
      
      def cost
        @cost ||= @inner.cost * @column_evaluators.collect { |column_evaluator| column_evaluator.cost }.reduce(0, :+)
      end

    end

  end

end
