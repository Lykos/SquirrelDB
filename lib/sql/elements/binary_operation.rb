require 'expression'

module Sql

  class BinaryOperation < Expression

    def initialize(operator, left, right)
      @operator = operator
      @left = left
      @right = right
    end

    attr_reader :operator, :left, :right

  end

end
