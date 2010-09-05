require 'schema/object_name'

module RubyDB

  module Schema
  
    class SchemaManager

      INTERNAL_TABLESPACE = "#internal#"
      SCHEMA_TABLE_NAME = "schema"

      def initialize( tuple_accessor, data_manager )
        @tuple_accessor = tuple_accessor
        @data_manager = data_manager
      end

      def get( object_name )
        # Those two have to be hardcoded, you need them to get schemas from the database.
        if object_name.scopes == [INTERNAL_TABLESPACE]
          INTERNAL_SCHEMATA[object_name]
        else
          # TODO get tuple with name = object_name from ObjectName.new( [INTERNAL_TABLESPACE], SCHEMA_TABLE_NAME )
        end
      end

    end

  end

end
