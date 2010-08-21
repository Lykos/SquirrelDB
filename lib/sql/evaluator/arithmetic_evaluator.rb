module Sql

  class ArithmeticEvaluator

    def initialize()

    end

    def visit_addition(addition)
      addition.left.visit + addition.right.visit
    end

    def visit_subtraction(subtraction)
      subtraction.left.visit - subtraction.right.visit
    end

    def visit_multiplication(multiplication)
      multiplication.left.visit + multiplication.right.visit
    end

    def visit_division(division)
      division.left.visit + division.right.visit
    end

    def visit_integer_constant(constant)
      constant.value
    end

  end
  
end
