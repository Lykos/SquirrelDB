require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'schema/type'

module SquirrelDB
  
  module Data

    class TableManager

      # TODO Find a better place for these constants
      INTERNAL_SCOPE = "#internal#"
      TOPLEVEL_SCOPE_ID = 1
      INTERNAL_TABLE_ID = {
        "schemata" => 1,
        "variables" => 2,
        "tables" => 3
      }
      
      INTERNAL_PAGE_NO = {
        1 => 1,
        2 => 2,
        3 => 3
      }
      
      include AST

      attr_accessor :internal_evaluator

      def get_page_no( table_id )
        if INTERNAL_PAGE_NO.has_key?(table_id)
          return INTERNAL_PAGE_NO[table_id]
        end
        table_id = get_object_id( table )
        # TODO Create constants for names in appropriate locations
        no = @internal_evaluator.select(
               ["page_no"],
               "tables",
               ["table_id"],
               [table_id],
               [SHORT]
             )
        # TODO Appropriate exception
        raise RuntimeError if no.length != 1
        no[0][0]
      end
      
      def get_variable_id( variable )
        if variable.kind_of?(ScopedVariable) && variable.scope.kind_of?(Variable) && variable.scope.name == INTERNAL_SCOPE
          return INTERNAL_TABLE_ID[table.variable.name]
        end
        if variable.kind_of?( ScopedVariable )
          scope_id = get_scope_id( variable.scope )
        else
          scope_id = TOPLEVEL_SCOPE_ID
        end
        # TODO Create constants for names in appropriate locations
        id = @internal_evaluator.select(
          ["variable_id"],
          "variables",
          ["scope_id", "variable_name"],
          [scope_id, variable.name],
          [Schema::Type::SHORT, Schema::Type::STRING]
        )
        # TODO Appropriate exception
        raise RuntimeError if id.length != 1
        id[0][0]
      end

      private
            
    end

  end
  
end
