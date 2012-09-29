require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'ast/common/column'
require 'schema/table_schema'
require 'schema/type'
require 'data/constants'
require 'schema/constants'

module SquirrelDB

  module Schema
  
    class SchemaManager
      
      include Constants
      
      include AST
      
      attr_writer :internal_evaluator, :table_manager

      def get(table)
        if table.kind_of?(ScopedVariable) && table.scope.kind_of?(Variable) && table.scope.variable.name == Data::Constants::INTERNAL_SCOPE
          INTERNAL_SCHEMATA[table.variable.name]
        else
          table_id = @table_manager.variable_id(table)
          TableSchema.new(
            @internal_evaluator.select(
              ["column_name", "type_id", "short_default", "boolean_default", "string_default", "double_default", "integer_default", "index"],
              "schemata",
              ["table_id"],
              [table_id]
            ).sort_by { |tuple| tuple[-1] }.map do |tuple|
              name = tuple[0]
              type = Type.by_id(tuple[1])
              index = tuple[-1]
              default = if type == Type::SHORT
                tuple[2]
              elsif type == Type::BOOLEAN
                tuple[3]
              elsif type == Type::STRING
                tuple[4]
              elsif type == Type::DOUBLE
                tuple[5]
              elsif type == Type::INTEGER
                tuple[6]
              else
                raise
              end
              if default.nil?
                Column.new(name, type, index)
              else
                Column.new(name, type, index, default)
              end
            end
          )
        end
      end
      
      def add(table_name, schema)
        table_id = @table_manager.add_table(table_name)
        schema.each_column do |c|
          @internal_evaluator.insert("schemata", ["table_id", "column_name", "type_id", c.type.name.downcase + "_default", "index"], [table_id, c.name.name, c.type.type_id, c.default.value, c.index])
        end
      end

    end

  end

end
