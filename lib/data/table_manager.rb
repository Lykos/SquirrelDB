require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'data/constants'
require 'errors/data_error'

module SquirrelDB
  
  module Data

    class TableManager

      include Constants
      
      include AST

      attr_writer :internal_evaluator, :sequence_manager, :data_initializer

      def page_no(table_id)
        if INTERNAL_PAGE_NOS.has_key?(table_id)
          return INTERNAL_PAGE_NOS[table_id]
        end
        # TODO Create constants for names in appropriate locations
        no = @internal_evaluator.select(
               ["page_no"],
               "tables",
               ["table_id"],
               [table_id]
             )
        # TODO Appropriate exception
        raise "More than one page no for table id #{table_id}" if no.length > 1
        raise "No page no for table id #{table_id}" if no.length == 0
        no[0][0]
      end
      
      # Returns true if the variable exists
      def has_variable?(variable)
        return true if internal?(variable)
        if variable.kind_of?(ScopedVariable)
          return false unless has_variable?(variable.scope)
          scope_id = variable_id(variable.scope)
        else
          scope_id = TOPLEVEL_SCOPE_ID
        end
        id = @internal_evaluator.select(
          ["variable_id"],
          "variables",
          ["scope_id", "variable_name"],
          [scope_id, variable.name]
        )
        raise DataError, "More than one table id for table #{variable.to_s}." if id.length > 1
        !id.empty?
      end
            
      # Returns the variable_id of the given variable.
      def variable_id(variable)
        if internal?(variable)
          return INTERNAL_TABLE_IDS[variable.variable.name]
        end
        if variable.kind_of?(ScopedVariable)
          scope_id = variable_id(variable.scope)
        else
          scope_id = TOPLEVEL_SCOPE_ID
        end
        id = @internal_evaluator.select(
          ["variable_id"],
          "variables",
          ["scope_id", "variable_name"],
          [scope_id, variable.name]
        )
        raise DataError, "More than one table id for table #{variable.to_s}." if id.length > 1
        raise DataError, "No table id for table #{variable.to_s}." if id.length == 0
        id[0][0]
      end
      
      # Adds a new table and returns the variable id
      def add_table(variable)
        table_id = add_variable(variable)
        page_no = @data_initializer.add_table
        @internal_evaluator.insert("tables", ["page_no", "table_id"], [page_no, table_id])
        table_id
      end
      
      # Adds a new variable to the variable table and returns the new variable id 
      def add_variable(variable)
        scope_id = variable.kind_of?(ScopedVariable) ? variable_id(variable.scope) : TOPLEVEL_SCOPE_ID
        variable_id = @sequence_manager.new_variable_id
        @internal_evaluator.insert("variables", ["scope_id", "variable_id", "variable_name"], [scope_id, variable_id, variable.name])
        variable_id
      end
      
      private
      
      def internal?(variable)
        variable.kind_of?(ScopedVariable) && variable.scope.kind_of?(Variable) && variable.scope.name == INTERNAL_SCOPE
      end
            
    end

  end
  
end
