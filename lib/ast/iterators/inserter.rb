require 'ast/iterators/rel_alg_iterator'
require 'ast/common/tuple'

module SquirrelDB

  module AST

    class Inserter
      
      def initialize(name, page_no, tuple_wrapper, schema, inner)
        @name = name
        @page_no = page_no
        @tuple_wrapper = tuple_wrapper
        @schema = schema
        @inner = inner
      end
      
      attr_reader :name, :page_no, :schema, :inner
      
      def ==(other)
        @name == other.name
        @page_no == other.page_no
        @schema == other.schema
        @inner == other.inner
      end
      
      def to_s
        "Inserter(#{@name.to_s}, #{@inner.to_s})"
      end
      
      def inspect
        "Inserter_{#{@schema.inspect}, #{@page_no}}(#{@name.inspect}, #{@inner.inspect})"
      end
      
      def hash
        @hash ||= [super, @name, @page_no, @schema, @inner].hash
      end

      def execute(state)
        values = @inner.get_all(state)
        @tuple_wrapper.add(@page_no, @schema, values)
      end
      
    end

  end
  
end
