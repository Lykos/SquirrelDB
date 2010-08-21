require 'simple_expression'
require 'arithmetic_expression'

module Sql

  class ConstantArithmeticExpression < ArithmeticExpression

    include ConstantExpression

  end
  
end
