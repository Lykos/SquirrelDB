require 'forwardable'

module RubyDB

  module Data
  
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

      def set( tids, table_schema, values )
        @tuple_accessor.get( tids ).collect { |t| table_schema.tuple_to_raw( t ) }
      end

      def set_tuple( tid, table_schema, value )
        table_schema.raw_to_tuple( @tuple_accessor.tuple_to_raw( tid ) )
      end

    end

  end
  
end
