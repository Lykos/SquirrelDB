require 'data/iterators/iterator'

module RubyDB

  module Data

    # Reads the table only the first time and keeps it in memory, so rewinding
    # is rather efficient.
    #
    class MemoryTableScanner < RelAlgIterator

      def initialize( table_name, tuple_wrapper, schema_manager, table_manager )
        super
        @table_name = table_name
        @tuple_wrapper = tuple_wrapper
        @schema_manager = schema_manager
        @table_manager = table_manager
      end

      def open
        super
        schema = @schema_manager.get( @table_name )
        tids = @table_manager.get_tids( @table_name )        
        @tuple_wrapper.get( tids, schema )
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
