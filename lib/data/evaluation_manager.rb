module Data

  class EvaluationManager

    def arithmetic_evaluator
      @arithmetic_evaluator ||= ArithmeticEvaluator.new
    end

    def boolean_evaluator
      @boolean_evaluator ||= BooleanEvaluator.new
    end

  end
  
end
