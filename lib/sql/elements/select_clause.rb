require 'syntactic_unit'

module Sql

  class SelectClause < SyntacticUnit

    def initialize(*columns)
      @columns = *columns
    end

    attr_reader :columns

  end

end
