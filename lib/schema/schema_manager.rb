require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'ast/common/column'
require 'schema/schema'
require 'schema/storage_type'
require 'data/constants'
require 'schema/constants'

module SquirrelDB

  module Schema
  
    class SchemaManager
      
      include Constants
      
      include AST
      
      attr_writer :internal_evaluator, :table_manager

      # Returns the schema of a given table
      # +table+:: A variable
      def get(table)
        if internal?(table)
          INTERNAL_SCHEMATA[table.variable.name]
        else
          table_id = @table_manager.variable_id(table)
          Schema.new(
            @internal_evaluator.select(
              ["column_name", "index", "type_id", "short_default", "boolean_default", "string_default", "double_default", "integer_default"],
              "schemata",
              ["table_id"],
              [table_id]
            ).sort_by { |tuple| tuple[1] }.map do |tuple|
              name = tuple[0]
              type = StorageType.by_id(tuple[2])
              case type 
              when StorageType::SHORT then tuple[3]
              when StorageType::BOOLEAN then tuple[4]
              when StorageType::STRING then tuple[5]
              when StorageType::DOUBLE then tuple[6]
              when StorageType::INTEGER then tuple[7]
              else
                raise
              end
              if default.nil?
                Column.new(name, type)
              else
                Column.new(name, type, default)
              end
            end
          )
        end
      end
      
      def has?(table)
        internal?(table) || @table_manager.has_variable?(table)
      end
      
      def add(table_name, schema)
        table_id = @table_manager.add_table(table_name)
        schema.each_column do |c|
          @internal_evaluator.insert("schemata", ["table_id", "column_name", "type_id", c.type.name.downcase + "_default", "index"], [table_id, c.name, c.type.type_id, c.default.value, c.index])
        end
      end
      
      private
      
      def internal?(table)
        table.kind_of?(ScopedVariable) && table.scope.kind_of?(Variable) && table.scope.variable.name == Data::Constants::INTERNAL_SCOPE       
      end

    end

  end

end
