require 'statement'

module Sql

  class SelectStatement < Expression

    def initialize( select_clause, from_clause, where_clause )
      @select_clause = select_clause
      @from_clause = from_clause
      @where_clause = where_clause
    end

    attr_reader :select_clause, :from_clause, :where_clause

  end

end
