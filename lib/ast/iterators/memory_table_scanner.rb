require 'ast/iterators/rel_alg_iterator'

module SquirrelDB

  module AST

    # Reads the table only the first time and keeps it in memory, so rewinding
    # is rather efficient.
    #
    class MemoryTableScanner < RelAlgIterator

      def initialize(name, page_no, tuple_wrapper, schema)
        super()
        @name = name
        @page_no = page_no
        @tuple_wrapper = tuple_wrapper
        @schema = schema
      end
      
      attr_reader :name, :page_no, :schema
      
      def ==(other)
        super && @name == other.name && page_no == other.page_no && @schema == other.schema
      end
      
      def hash
        @hash ||= [super, @name, @page_no, @schema].hash
      end

      def to_s
        "MemoryTableScanner(#{@name.to_s})"
      end
      
      def inspect
        "MemoryTableScanner_{#{@schema.inspect}, #{@page_no}}(#{@name.inspect})"
      end

      def itopen(state)
        super
        @tuples = @tuple_wrapper.get_all(@page_no, @schema)
        @index = 0
      end

      def next_item
        super
        return nil if @index >= @tuples.length
        t = @tuples[@index]
        @index += 1
        t
      end
      
      def size
        @tuples.size
      end
      
      def cost
        @tuples.size
      end

      def close
        super
        @tuples = nil
      end

      def rewind
        super
        @index = 0
      end
      
    end

  end
  
end
