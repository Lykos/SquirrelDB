require 'syntactic_parser'

module Sql

  class Verifier

    def initialize( syntactic_parser=SyntacticParser.new )
      @syntactic_parser = syntactic_parser
    end

    def process( string )
      statement = @syntactic_parser.process( string )
      return statement
      raise unless statement.kind_of?( Statement )
      statement.visit( self )
    end

    def visit_select_statement( select_statement )
      raise unless select_statement.select_clause.kind_of?( SelectClause )
      raise unless select_statement.from_clause.kind_of?( FromClause )
    end

  end
  
end
