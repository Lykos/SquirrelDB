require 'sql/elements/variable'

module RubyDB

  module Sql

    class Renaming < SyntacticUnit

      def initialize( expression, name=Variable.new( expression.to_s ) )
        @expression = expression
        @name = name
      end

      attr_reader :expression, :name

    end

  end

end
