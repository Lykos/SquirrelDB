require 'sql/elements/syntactic_unit'

module SquirrelDB

  module AST

    class WildCard < SyntacticUnit

      def to_s
        '*'
      end

    end

  end

end
