require 'ast/syntatctic_unit'

module SquirrelDB

  module AST

    class LinkedTable < SyntacticUnit

      def initialize( schema, page_no )
        @schema = schema
        @page_no = page_no
      end

      attr_reader :schema, :page_no
      
    end

  end

end
