require 'arithmetic_expression'
require 'unary_expression'

module Sql

  class UnaryMinus < ArithmeticExpression

    include unary_expression

  end

end
