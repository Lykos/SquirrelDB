require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class Variable < SyntacticUnit

      def initialize( name )
        @name = name
      end

      attr_reader :name

      def to_s
        @name
      end

      def inspect
        @name
      end

    end

  end

end
