require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class SelectStatement < SyntacticUnit

      def initialize( select_clause, from_clause, where_clause )
        @select_clause = select_clause
        @from_clause = from_clause
        @where_clause = where_clause
      end

      attr_reader :select_clause, :from_clause, :where_clause

      def to_s
        @select_clause.to_s + " " + @from_clause.to_s + " " + @where_clause.to_s
      end

      def inspect
        "SelectStatement( " + @select_clause.inspect + ", " +
          @from_clause.inspect + ", " + @where_clause.inspect + " )"
      end

      def ==(other)
        super && @select_clause == other.select_clause && @from_clause == other.from_clause && @where_clause == other.where_clause
      end

    end

  end

end
