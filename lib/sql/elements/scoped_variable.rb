require RubyDB

  module Sql

    class ScopedVariable < SyntacticUnit

      def initialize( scope, variable )
        @scope = scope
        @variable = variable
      end

      attr_reader :scope, :variable

    end

  end

end
