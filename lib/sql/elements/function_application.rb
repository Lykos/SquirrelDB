require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class FunctionApplication < SyntacticUnit

      def initialize( function, parameters )
        @function = function
        @parameters = parameters
      end

      attr_reader :function, :parameters

    end

  end
  
end
