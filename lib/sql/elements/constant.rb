require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class Constant < SyntacticUnit

      def initialize( value, type )
        @value = value
        @type = type
      end

      attr_reader :value, :type

      def to_s
        @value.to_s
      end

    end

  end

end
