require 'data/iterators/iterator'

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
        @tuples[@index]
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
