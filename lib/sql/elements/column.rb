module Sql

  class Column

    def initialize( expression, name=expression.to_s )
      @expression = expression
      @name = name
    end

    attr_reader :expression, :name
    
  end

end
