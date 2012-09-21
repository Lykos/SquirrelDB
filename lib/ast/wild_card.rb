require 'sql/elements/syntactic_unit'

module SquirrelDB

  module Sql

    class WildCard < SyntacticUnit

      def to_s
        '*'
      end

    end

  end

end
