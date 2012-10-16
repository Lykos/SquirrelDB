require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'ast/common/column'
require 'schema/schema'
require 'schema/storage_type'
require 'schema/constants'

module SquirrelDB

  module Schema
  
    module Constants
      
      include AST
      
      # The schemas of internal tables have to be hard-coded, we need them to get schemas from the database.
      INTERNAL_SCHEMATA = {
        # TODO Make this dynamic and depending on the types
        "schemata" => Schema.new([Column.new("table_id", StorageType::SHORT),
                                  Column.new("column_name", StorageType::STRING),
                                  Column.new("type_id", StorageType::SHORT),
                                  Column.new("short_default", StorageType::SHORT),
                                  Column.new("boolean_default", StorageType::BOOLEAN),
                                  Column.new("string_default", StorageType::STRING),
                                  Column.new("double_default", StorageType::DOUBLE),
                                  Column.new("integer_default", StorageType::INTEGER),
                                  Column.new("index", StorageType::SHORT)]),
        "variables" => Schema.new([Column.new("scope_id", StorageType::SHORT),
                                   Column.new("variable_name", StorageType::STRING),
                                   Column.new("variable_id", StorageType::SHORT)]),
        "tables" => Schema.new([Column.new("table_id", StorageType::SHORT),
                                Column.new("page_no", StorageType::SHORT)]),
      }

    end

  end

end
