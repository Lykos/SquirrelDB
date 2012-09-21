require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class WildCard < SyntacticUnit

      def to_s
        '*'
      end

    end

  end

end
