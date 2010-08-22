require 'expression'

module Sql

  class UnaryOperation < Expression

    def initialize(operator, inner)
      @operator = operator
      @inner = inner
    end

    attr_reader :operator, :inner

  end
  
end
