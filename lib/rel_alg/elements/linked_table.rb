require 'sql/elements/syntatctic_unit'

module RubyDB

  module RelAlg

    class LinkedTable < SyntacticUnit

      def initialize( schema, page_no )
        @schema = schema
        @page_no = page_no
      end

      attr_reader :schema, :page_no
      
    end

  end

end
