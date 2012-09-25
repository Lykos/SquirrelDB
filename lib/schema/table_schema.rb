require 'ast/common/tuple'

module SquirrelDB
  
  module Schema

    class TableSchema

      def initialize( columns )
        @columns = columns
        @indices = {}
        @types = {}
      end

      def length
        @columns.length
      end
      
      def raw_to_tuple( raw_string )
        fields = []
        @columns.each do |c|
          raw_string, field = c.to_field( raw_string )
          fields.push( field )
        end
        raise unless raw_string.empty?
        Tuple.new( fields )
      end

      def tuple_to_raw( tuple )
        # TODO Choose appropriate exception
        raise RuntimeError if tuple.fields.length != @columns.length
        (0...@columns.length).inject( "" ) { |raw, i| raw + @columns[i].to_raw( tuple[i] ) }
      end
      
      def get_column(column_name)
        @columns.find { |col| col.name == column_name }
      end

      def get_index( column_name )
        @indices[column_name] ||= @columns.find_index { |col| col.name == column_name }
      end
      
      def get_type( column_name )
        @types[column_name] ||= @columns.find { |col| col.name == column_name }.type
      end

      def +( other )
        TableSchema.new( @columns + other.columns )
      end

    end
  
  end

end