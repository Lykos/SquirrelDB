module SquirrelDB

  module AST

    class TableCreator

      def initialize(variable, schema, schema_manager)
        @variable = variable
        @schema = schema
        @schema_manager = schema_manager
      end

      attr_reader :variable, :schema

      def to_s
        "TableCreator( #{@variable.to_s}, #{@schema.to_s} )"
      end

      def inspect
        "TableCreator( #{@variable.inspect}, #{@schema.inspect} )"
      end

      def ==(other)
        super && @variable == other.variable && @schema == other.schema
      end
      
      def hash
        @hash ||= [super, @variable, @schema].hash
      end
      
      def query?
        false
      end
      
      def execute(state)
        @schema_manager.add(@variable, @schema)
      end

    end

  end

end
