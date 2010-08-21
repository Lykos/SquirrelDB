require 'binary_expression'
require 'arithmetic_expression'

module Sql

  class BinaryArithmeticExpression < ArithmeticExpression

    include BinaryExpression

  end
  
end
