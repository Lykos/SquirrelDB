require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class Selection < SyntacticUnit

      def initialize( expression, table )
        @expression = expression
        @table = table
      end

      attr_reader :expression, :table

      def to_s
        "Selection_{ " + @expression.to_s + " }( " + @table.to_s + " )"
      end

      def inspect
        "Selection_{ " + @expression.to_s + " }( " + @table.to_s + " )"
      end

      def ==(other)
        super && @expression == other.expression && @table == other.table
      end

    end

  end

end
