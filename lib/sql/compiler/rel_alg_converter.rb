module Sql

  class RelAlgConverter

    def initialize( verifier=Verifier.new )
      @verifier = verifier
    end

    include Operators

    def compile( string )
      select_statement = @verifier.verify( string )
      select_statement.visit( self )
    end

    def visit_select_statement( select_statement )
      BinaryOperation.new(
        PROJECT,
        select_statement.select_clause.visit( self ),
        BinaryOperation.new(
          SELECT,
          select_statement.where_clause.visit( self ),
          select_statement.from_clause.visit( self )
        )
      )
    end

    def visit_select_clause( select_clause )
      select_clause.columns.collect { |table| table.visit( self ) }
    end

    def visit_table( table )
      Table.new( table.expression.visit( self ), table.name )
    end

    def visit_where_clause( where_clause )
      where_clause.expression.visit( self )
    end

    def visit_from_clause( from_clause )
      tables = from_clause.tables.collect { |column| column.visit( self ) }
      if tables.empty?
        return Table::DUAL
      else
        until tables.length == 1
          tables.push( FunctionApplication.new( CARTESIAN, *tables.shift(2) ) )
        end
        tables[0]
      end
    end

    def visit_column( column )
      Column.new( column.expression.visit( self ), column.name )
    end

    def visit_function_application( function_application )
      FunctionApplication.new(
        function_application.function,
        function_application.parameters.collect { |param| param.visit( self ) }
      )
    end

    def visit_constant( constant )
      Constant.new( constant.name )
    end

    def visit_variable( variable )
      Variable.new( variable.name )
    end

  end

end
