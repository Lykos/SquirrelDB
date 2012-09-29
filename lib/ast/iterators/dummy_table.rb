require 'ast/iterators/rel_alg_iterator'
require 'ast/common/tuple'

module SquirrelDB

  module AST

    # Divide this into dummytable and dummyiterator
    class DummyTable < RelAlgIterator
      
      def initialize(schema, tuple)
        @schema = schema
        @tuple = tuple
      end
      
      attr_reader :schema, :tuple
      
      def hash
        @hash ||= [super, @tuple].hash
      end
      
      def to_s
        "DummyTable( #{@tuple.to_s} )"
      end
      
      def inspect
        "DummyTable( #{@tuple.inspect} )"
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
      
    end

  end
  
end
