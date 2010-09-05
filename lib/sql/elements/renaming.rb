require 'sql/elements/variable'

module RubyDB

  module Sql

    class Renaming < SyntacticUnit

      def initialize( expression, name )
        @expression = expression
        @name = name
      end

      attr_reader :expression, :name

      def to_s
        @expression.to_s + " as " + @name.to_s
      end

      def inspect
        @expression.inspect + " as " + @name.inspect
      end

      def ==(other)
        super && @expression == other.expression && @name == other.name
      end

      def visit( visitor )
        let_visit( visitor, @expression.visit( visitor ), @name.visit( visitor ) )
      end

    end

  end

end
