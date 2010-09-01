require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class FromClause < SyntacticUnit

      def initialize( tables )
        @tables = tables
      end

      attr_reader :tables

      def to_s
        "from " + @tables.collect { |c| c.to_s }.join( ", " )
      end

      def inspect
        "FromClause( " + @tables.collect { |c| c.inspect }.join( ", " ) + " )"
      end
    end

  end

end
