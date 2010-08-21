module Sql

  module UnaryExpression

    def initialize(inner)
      @inner = inner
    end

    attr_reader :inner

  end
  
end
