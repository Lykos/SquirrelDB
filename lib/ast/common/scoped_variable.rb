require 'ast/common/element'

module SquirrelDB

  module AST

    class ScopedVariable < Element

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
        let_visit( visitor, @scope.accept( visitor ), @variable.accept( visitor ) )
      end

      def evaluate( state )
        st = state
        @scope.collect { |s| st = st.get_scope( s ) }
        st.get_variable( @variable )
      end

    end

  end

end
