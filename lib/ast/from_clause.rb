require 'ast/syntactic_unit'

module SquirrelDB

  module AST

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

      def ==(other)
        super && @tables == other.tables
      end

      def accept( visitor )
        let_visit( visitor, @tables.collect { |t| t.accept( visitor ) } )
      end

    end

  end

end
