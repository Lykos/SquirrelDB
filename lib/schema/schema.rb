require 'data/tuple'
require 'ast/common/column'
require 'errors/internal_error'
require 'errors/encoding_error'

module SquirrelDB
  
  module Schema

    class Schema
      
      include Data

      def initialize(columns)
        @columns = columns
      end
            
      attr_reader :columns
      
      def ==(other)
        other.class == TableSchema && @columns == other.columns
      end
      
      def each_column(&block)
        @columns.each(&block)
      end

      def to_s
        "Schema( " + @columns.map { |c| c.to_s }.join(", ") + " )"
      end
      
      def inspect
        "Schema( " + @columns.map { |c| c.inspect }.join(", ") + " )"
      end
      
      def hash
        @hash ||= [self.class, @columns].hash
      end

      def length
        @length ||= @columns.length
      end
      
      # Creates a tuple from a binary string.
      def raw_to_tuple(raw)
        raise EncodingError, "The raw string from which we read tuples has an invalid encoding." unless raw.encoding == Encoding::BINARY
        fields = @columns.map { |col| col.type.load(raw) }
        raise StorageError, "There is #{raw.length} left over after reading the tuple #{fields} with schema #{self}." unless raw.empty?
        Tuple.new(fields)
      end

      def tuple_to_raw(tuple)
        raise InternalError, "Tuple #{tuple.to_s} and schema #{to_s} have different lengths." if tuple.values.length != @columns.length
        raw = @columns.zip(tuple.values).map do |col_val|
          col, val = col_val
          col.type.store(val)
        end.join
      end
      
      def column(column_name)
        @columns.find { |col| col.name == column_name }
      end

      def index(column_name)
        @columns.find_index { |col| col.name == column_name }
      end

      def +(other)
        TableSchema.new(@columns + other.columns)
      end

    end
  
  end

end