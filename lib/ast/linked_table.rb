require 'ast/element'

module SquirrelDB

  module AST

    class LinkedTable < Element

      def initialize( schema, name, page_no )
        @schema = schema
        @page_no = page_no
      end

      attr_reader :schema, :page_no
      
    end

  end

end
