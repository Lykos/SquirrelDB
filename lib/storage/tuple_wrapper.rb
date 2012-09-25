require 'forwardable'

module SquirrelDB

  module Storage
  
    class TupleWrapper

      def initialize( tuple_accessor )
        @tuple_accessor = tuple_accessor
      end

      extend Forwardable

      def_delegators :@tuple_accessor, :remove, :remove_tuple, :close

      def get( tids, table_schema )
        @tuple_accessor.get( tids ).collect { |t| table_schema.raw_to_tuple( t ) }
      end

      def get_tuple( tid, table_schema )
        table_schema.raw_to_tuple( @tuple_accessor.get( tid ) )
      end

      def set( tids, table_schema, tuples )
        @tuple_accessor.set( tids, tuples.collect { |t| table_schema.tuple_to_raw( t ) } )
      end

      def set_tuple( tid, table_schema, tuple )
        @tuple_accessor.set_tuple( tid, table_schema.tuple_to_raw( tuple ) )
      end

      def add( page_no, table_schema, tuples )
        @tuple_accessor.add( tuples.collect { |t| table_schema.tuple_to_raw( t ) }, page_no )
      end

      def add_tuple( page_no, table_schema, tuple )
        @tuple_accessor.add_tuple( table_schema.tuple_to_raw( tuple ), page_no )
      end

      def get_all( page_no, table_schema )
        @tuple_accessor.get_all( page_no ).collect { |t| table_schema.tuple_to_raw( t ) }
      end

    end

  end
  
end
