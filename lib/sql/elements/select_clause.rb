require 'column'

module Sql

  class SelectClause

    def initialize(*columns)
      @columns = *columns
    end

    attr_reader :tables

  end

end
