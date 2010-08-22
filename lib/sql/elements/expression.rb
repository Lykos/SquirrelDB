require 'syntactic_unit'

module Sql

  class Expression < SyntacticUnit

    def |(other)
      Disjunction.new(self, other)
    end

    def &(other)
      Conjunction.new(self, other)
    end

    def +(other)
      Addition.new(self, other)
    end

    def -(other)
      Subtraction.new(self, other)
    end
    
    def *(other)
      Multiplication.new(self, other)
    end

    def /(other)
      Division.new(self, other)
    end

    def +@
      self
    end

    def -@
      UnaryMinus.new(self)
    end

  end

end
