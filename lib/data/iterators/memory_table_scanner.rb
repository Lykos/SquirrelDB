require 'data/iterators/rel_alg_iterator'
require 'data/iterators/table_scanner'

module RubyDB

  module Data

    # Reads the table only the first time and keeps it in memory, so rewinding
    # is rather efficient.
    #
    class MemoryTableScanner < RelAlgIterator

      def initialize( table_name )
        super
        @table_name = table_name
      end

      def open
        super
        table_scanner = TableScanner.new( @table_name )
        table_scanner.open
        @tuples = []
        while (t = table_scanner.next_item)
          @tuples.push( t )
        end
        table_scanner.close
        @index = 0
      end

      def next_item
        super
        @tuples[@index]
      end

      def close
        super
      end

      def rewind
        raise unless @open
        @index = 0
      end
      
    end

  end
  
end
