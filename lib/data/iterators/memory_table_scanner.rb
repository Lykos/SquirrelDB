require 'data/iterators/rel_alg_iterator'

module RubyDB

  module Data

    # Reads the table only the first time and keeps it in memory, so rewinding
    # is rather efficient.
    #
    class MemoryTableScanner < RelAlgIterator

      def initialize( page_no, tuple_wrapper, schema )
        super()
        @page_no = page_no
        @tuple_wrapper = tuple_wrapper
        @schema = schema
      end

      def open
        super
        @tuples = @tuple_wrapper.get_all( @table_page_no, @schema )
        @index = 0
      end

      def next_item
        super
        raise if @index >= @tuples.length
        @tuples[@index]
      end
      
      def size
        @tuples.size
      end
      
      def cost
        @tuples.size
      end

      def close
        @tuples = nil
        super
      end

      def rewind
        @index = 0
        super
      end
      
    end

  end
  
end
