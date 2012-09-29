require 'ast/common/tuple'
require 'ast/common/column'
require 'conversion_util'

module SquirrelDB
  
  module Schema

    class TableSchema

      def initialize(columns)
        @columns = columns
        @indices = {}
        @types = {}
      end
      
      include ConversionUtil
      
      attr_reader :columns
      
      def ==(other)
        other.class == TableSchema && @columns == other.columns
      end
      
      def each_column(&block)
        @columns.each(&block)
      end

      def to_s
        "TableSchema( " + @columns.map { |c| "#{c.name.to_s}::#{c.type.to_s}#{c.has_default? ? " = " + c.default.to_s : ""}" }.join(", ") + " )"
      end
      
      def inspect
        "TableSchema( " + @columns.map { |c| c.inspect }.join(", ") + " )"
      end
      
      def hash
        @hash ||= [self.class, @columns].hash
      end

      def length
        @columns.length
      end
      
      def raw_to_tuple(raw_string)
        fields = []
        @columns.each do |col|
          field = raw_to_field(raw_string, col.type)
          fields.push(field)
        end
        raise unless raw_string.empty?
        AST::Tuple.new(fields)
      end

      def tuple_to_raw(tuple)
        # TODO Choose appropriate exception
        raise "Tuple #{tuple.to_s} and schema #{to_s} have different lengths." if tuple.values.length != @columns.length
        @columns.zip(tuple.values).map.with_index do |col_tup|
          col, tup = col_tup
          field_to_raw(tup, col.type)
        end.join("")
      end
      
      def column(column_name)
        @columns.find { |col| col.name == column_name }
      end

      def index(column_name)
        @indices[column_name] ||= @columns.find { |col| col.name == column_name }.index
      end
      
      def type(column_name)
        @types[column_name] ||= @columns.find { |col| col.name == column_name }.type
      end

      def +(other)
        TableSchema.new(@columns + other.columns.collect { |col| Column.new(col.name, col.type, col.index + @columns.length, col.default) })
      end

    end
  
  end

end