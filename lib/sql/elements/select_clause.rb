require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class SelectClause < SyntacticUnit

      def initialize( columns )
        @columns = columns
      end

      attr_reader :columns

      def to_s
        "select " + @columns.collect { |c| c.to_s }.join( ", " )
      end

      def inspect
        "SelectClause( " + @columns.collect { |c| c.inspect }.join( ", " ) + " )"
      end

    end

  end

end
