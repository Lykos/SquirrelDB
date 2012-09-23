require 'ast/iterators/memory_table_scanner'
require 'ast/visitors/transform_visitor'

module SquirrelDB

  module Data

    class Linker < AST::TransformVisitor
      
      include AST
      
      def initialize(tuple_wrapper, table_manager)
        @tuple_wrapper = tuple_wrapper
        @table_manager = table_manager
      end

      def process( statement )
        statement.accept( self )
      end
      
      def visit_pre_linked_table(schema, name, table_id)
        page_no = @table_manager.get_page_no(table_id)
        MemoryTableScanner.new(name, page_no, @tuple_wrapper, schema)
      end
      
    end

  end

end