require 'sql/elements/syntactic_unit'

module SquirrelDB

  module Sql

    class SelectClause < SyntacticUnit

      def initialize( columns )
        @columns = columns
      end

      attr_reader :columns

      def ==(other)
        super && @columns == other.columns
      end

      def to_s
        "select " + @columns.collect { |c| c.to_s }.join( ", " )
      end

      def inspect
        "SelectClause( " + @columns.collect { |c| c.inspect }.join( ", " ) + " )"
      end

      def accept( visitor )
        let_visit( visitor, @columns.collect { |c| c.accept( visitor ) } )
      end

    end

  end

end