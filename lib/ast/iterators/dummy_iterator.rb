require 'ast/iterators/rel_alg_iterator'
require 'ast/common/column'
require 'ast/common/constant'
require 'schema/schema'
require 'schema/expression_type'

module SquirrelDB

  module AST

    class DummyIterator < RelAlgIterator
            
      def initialize(types, expression_evaluators)
        @types = types
        @expression_evaluators = expression_evaluators
      end
      
      attr_reader :types, :expression_evaluators
    
      def hash
        @hash ||= [super, @expression_evaluators].hash
      end
      
      def ==(other)
        super && @types == other.types && @expression_evaluators == other.expression_evaluators
      end
      
      def to_s
        "DummyTable( " + @schema.to_s + ", [ " + @expression_evaluators.collect { |e| e.to_s }.join(",") + " ] )"
      end
      
      def inspect
        "DummyTable( " + @schema.to_s + ", [ " + @expression_evaluators.collect { |e| e.inspect }.join(",") + " ] )"
      end
      
      def length
        @length ||= @types.length
      end

      def itopen(state)
        super
        @start = true
      end

      def next_item
        super
        return nil unless @start
        @start = false
        @expression_evaluators.collect { |ev| ev.evaluate(@state) }
      end

      def rewind
        @start = true
        super
      end
      
      include Schema
      
      DUAL_COLUMN = Column.new("value", "string")
      DUAL_SCHEMA = Schema::Schema.new([DUAL_COLUMN])
      DUAL_VALUES = [Constant.new("X", ExpressionType::STRING)]
      DUAL_TABLE = DummyIterator.new(DUAL_SCHEMA, DUAL_VALUES)
      
    end

  end
  
end
