module Sql

  class Table

    def initialize( expression, name=expression.to_s )
      @expression = expression
      @rename = rename
    end

    attr_reader :expresion, :expression

    DUAL = Table.new( 'dual' )

  end

end
