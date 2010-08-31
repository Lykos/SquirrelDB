require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class SelectClause < SyntacticUnit

      def initialize( columns )
        @columns = columns
      end

      attr_reader :columns

    end

  end

end
