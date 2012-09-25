require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'ast/common/column'
require 'schema/table_schema'
require 'schema/type'
require 'data/table_manager'

module SquirrelDB

  module Schema
  
    class SchemaManager
      
      include AST

      INTERNAL_SCHEMATA = {
        "schemata" => TableSchema.new([Column.new(Type::SHORT, "table_id", 0),
                                       Column.new(Type::SHORT, "column_name", 1),
                                       Column.new(Type::SHORT, "type_id", 2),
                                       Column.new(Type::SHORT, "short_default", 3),
                                       Column.new(Type::BOOLEAN, "boolean_default", 4),
                                       Column.new(Type::STRING, "string_default", 5),
                                       Column.new(Type::DOUBLE, "double_default", 6),
                                       Column.new(Type::INTEGER, "integer_default", 7),
                                       Column.new(Type::SHORT, "index", 8)]),
        "variables" => TableSchema.new([Column.new(Type::SHORT, "scope_id", 0),
                                        Column.new(Type::STRING, "variable_name", 1),
                                        Column.new(Type::SHORT, "variable_id", 2)]),
        "tables" => TableSchema.new([Column.new(Type::SHORT, "table_id", 0),
                                     Column.new(Type::SHORT, "page_no", 1)]),
      }
      
      attr_accessor :internal_evaluator, :table_manager

      def get( table )
        # The schemas of internal tables have to be hard-coded, we need them to get schemas from the database.
        if table.kind_of?(ScopedVariable) && table.scope.kind_of?(Variable) && table.scope.variable.name == Data::TableManager::INTERNAL_SCOPE
          INTERNAL_SCHEMATA[table.variable.name]
        else
          table_id = @table_manager.get_variable_id(table)
          TableSchema.new(
            @internal_evaluator.select(
              ["column_name", "type_id", "short_default", "boolean_default", "string_default", "double_default", "integer_default", "index"],
              "schemata",
              ["table_id"],
              [table_id],
              [Type::SHORT]
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
              Column.new(name, type, default, index)
            end
          )
        end
      end
      
      def add( table_name, schema )
        
      end

    end

  end

end
