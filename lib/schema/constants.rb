require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'ast/common/column'
require 'schema/table_schema'
require 'schema/type'
require 'schema/constants'

module SquirrelDB

  module Schema
  
    module Constants
      
      include AST
      
      # The schemas of internal tables have to be hard-coded, we need them to get schemas from the database.
      INTERNAL_SCHEMATA = {
        # TODO Make this dynamic and depending on the types
        "schemata" => TableSchema.new([Column.new("table_id", Type::SHORT, 0),
                                       Column.new("column_name", Type::STRING, 1),
                                       Column.new("type_id", Type::SHORT, 2),
                                       Column.new("short_default", Type::SHORT, 3),
                                       Column.new("boolean_default", Type::BOOLEAN, 4),
                                       Column.new("string_default", Type::STRING, 5),
                                       Column.new("double_default", Type::DOUBLE, 6),
                                       Column.new("integer_default", Type::INTEGER, 7),
                                       Column.new("index", Type::SHORT, 8)]),
        "variables" => TableSchema.new([Column.new("scope_id", Type::SHORT, 0),
                                        Column.new("variable_name", Type::STRING, 1),
                                        Column.new("variable_id", Type::SHORT, 2)]),
        "tables" => TableSchema.new([Column.new("table_id", Type::SHORT, 0),
                                     Column.new("page_no", Type::SHORT, 1)]),
      }

    end

  end

end
