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

      def accept( visitor )
        let_visit( visitor, @scope.collect { |s| s.accept( visitor ) }, @variable.accept( visitor ) )
      end

      def evaluate( state )
        st = state
        @scope.collect { |s| st = st.get_scope( s ) }
        st.get_variable( @variable )
      end

    end

  end

end
