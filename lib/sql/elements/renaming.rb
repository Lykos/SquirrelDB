require 'sql/elements/variable'

module RubyDB

  module Sql

    class Renaming < SyntacticUnit

      def initialize( expression, name=Variable.new( expression.to_s ) )
        @expression = expression
        @name = name
      end

      attr_reader :expression, :name

      def to_s
        @expression.to_s + " as " + @name.to_s
      end

      def inspect
        @expression.inspect + " as " + @name.to_s
      end

    end

  end

end
