require 'ast/iterators/rel_alg_iterator'
require 'data/state'
require 'forwardable'

module SquirrelDB

  module AST
  
    class Selector < RelAlgIterator
  
      def initialize( expression_evaluator, inner )
        super()
        @expression_evaluator = expression_evaluator
        @inner = inner
      end
      
      attr_reader :expression_evaluator, :inner
      
      extend Forwardable
      
      def_delegators :@inner, :types
  
      def itopen(state)
        super
        inner.itopen(state)
      end
      
      def close
        super
        inner.close
      end
      
      def rewind
        super
        inner.rewind
      end
      
      def ==(other)
        super && @expression_evaluator == other.expression_evaluator && @inner == other.inner 
      end
      
      def hash
        @hash ||= [super, @expression_evaluator, @inner].hash
      end
    
      def inspect
        "Selector_{#{@expression_evaluator.inspect}}(#{@inner.inspect})"
      end
      
      def to_s
        "Selector_{#{@expression_evaluator.to_s}}(#{@inner.to_s})"
      end
      
      def next_item
        super
        while (t = @inner.next_item)
          return t if @expression_evaluator.evaluate(Data::State.new(t, @state))
        end
        nil
      end
  
    end
  
  end

end
