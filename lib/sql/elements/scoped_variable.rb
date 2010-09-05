require 'syntactic_unit'

module RubyDB

  module Sql

    class ScopedVariable < SyntacticUnit

      def initialize( scope, variable )
        @scope = scope
        @variable = variable
      end

      attr_reader :scope, :variable

      def to_s
        @scope.to_s + "." + @variable.to_s
      end

      def inspect
        @scope.inspect + "." + @variable.inspect
      end

      def ==(other)
        super && @scope == other.scope && @variable == other.variable
      end

      def visit( visitor )
        let_visit( visitor, @scope.collect { |s| s.visit( visitor ) }, @variable.visit( visitor ) )
      end

    end

  end

end