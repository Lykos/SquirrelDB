require 'ast/common/element'

module SquirrelDB

  module AST

    class PreLinkedTable < Element

      def initialize( schema, name, table_id )
        @schema = schema
        @name = name
        @table_id = table_id
      end

      attr_reader :schema, :name, :table_id
      
      def accept(visitor)
        let_visit(visitor, schema, name, table_id)
      end
      
    end

  end

end
