require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class FromClause < SyntacticUnit

      def initialize( tables )
        @tables = tables
      end

      attr_reader :tables

    end

  end

end
