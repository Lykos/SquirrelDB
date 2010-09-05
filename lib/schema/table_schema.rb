module RubyDB
  
  module Schema

    class TableSchema

      def initialize( columns )
        @columns = columns
      end

      attr_reader :columns

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
        raise if tuple.fields.length != @columns.length
        (0...@columns.length).inject( "" ) { |raw, i| raw + @columns[i].to_raw( tuple[i] ) }
      end

    end
  
  end

end