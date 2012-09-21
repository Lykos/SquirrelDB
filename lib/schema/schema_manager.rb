require 'sql/elements/scoped_variable'
require 'sql/elements/variable'
require 'schema/table_schema'
require 'schema/type'
require 'data/table_manager'

module SquirrelDB

  module Schema
  
    class SchemaManager

      INTERNAL_SCHEMATA = [
        "schemata" => TableSchema.new([Column.new("table_id", SHORT), Column.new("column_name", SHORT), Column.new("index", SHORT), Column.new("type_id", SHORT)]),
        "variables" => TableSchema.new([Column.new("scope_id", SHORT), Column.new("variable_name", STRING), Column.new("variable_id", SHORT)]),
        "tables" => TableSchema.new([Column.new("table_id", SHORT), Column.new("page_no", SHORT)]),
      ]
      
      attr_accessor internal_evaluator, table_manager

      def get( table )
        # The schemas of internal tables have to be hard-coded, we need them to get schemas from the database.
        if table.kind_of?(SQL::ScopedVariable) && table.scope.kind_of?(SQL::Variable) && table.scope.variable.name == Data::TableManager::INTERNAL_SCOPE
          INTERNAL_SCHEMATA[table.variable.name]
        else
          table_id = @table_manager.get_variable_id(table)
          TableSchema.new(
            @internal_evaluator.select(
              ["column_name", "index", "type_id"],
              "schemata",
              ["table_id"],
              [table_id],
              [SHORT]
            ).sort_by { |column| column[1] }.map do |column|
              Column.new(column[0], Type.by_id(column[2]))
            end
          )
        end
      end

    end

  end

end
