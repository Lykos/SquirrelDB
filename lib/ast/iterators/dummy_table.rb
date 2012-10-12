require 'ast/iterators/rel_alg_iterator'
require 'ast/common/column'
require 'ast/common/constant'
require 'schema/table_schema'
require 'schema/expression_type'

module SquirrelDB

  module AST

    class DummyIterator < RelAlgIterator
            
      def initialize(schema, expressions)
        @schema = schema
        @expressions = expressions
      end
      
      attr_reader :schema, :tuple
      
      def hash
        @hash ||= [super, @tuple].hash
      end
      
      def to_s
        "DummyTable( " + @schema.to_s + ", [ " + @expressions.collect { |e| e.to_s }.join(",") + " ] )"
      end
      
      def inspect
        "DummyTable( " + @schema.to_s + ", [ " + @expressions.collect { |e| e.inspect }.join(",") + " ] )"
      end

      def itopen(state)
        super
        @start = true
      end

      def next_item
        super
        return nil unless @start
        @start = false
        @tuple.dup
      end

      def rewind
        @start = true
        super
      end
      
      DUAL_COLUMN = Column.new("value", "string")
      DUAL_SCHEMA = TableSchema.new([DUAL_COLUMN])
      DUAL_VALUES = [Constant.new("X", ExpressionType::STRING)]
      DUAL_TABLE = DummyIterator.new(DUAL_SCHEMA, DUAL_VALUES)
      
    end

  end
  
end
