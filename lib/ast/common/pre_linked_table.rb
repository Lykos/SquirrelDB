require 'ast/common/element'

module SquirrelDB

  module AST

    class PreLinkedTable < Element

      def initialize(schema, names, table_id)
        @schema = schema
        @names = names
        @table_id = table_id
      end

      attr_reader :schema, :names, :table_id
      
      def to_s
        "PreLinkedTable( #{@schema.to_s}, #{@name.to_s}, #{@table_id} )"
      end
      
      def inspect
        "PreLinkedTable( #{@schema.inspect}, #{@name.inspect}, #{@table_id} )"
      end
      
      def ==(other)
        super && @schema == other.schema && @names == other.names && @table_id == other.table_id
      end
      
      def hash
        @hash ||= [super, @schema, @names, @table_id].hash
      end
      
    end

  end

end
