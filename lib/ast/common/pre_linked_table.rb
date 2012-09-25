require 'ast/common/element'

module SquirrelDB

  module AST

    class PreLinkedTable < Element

      def initialize(schema, name, table_id, read_only)
        @schema = schema
        @name = name
        @table_id = table_id
        @read_only = read_only
      end

      attr_reader :schema, :name, :table_id, :read_only
      
      def accept(visitor)
        let_visit(visitor, schema, name, table_id, read_only)
      end
      
    end

  end

end
