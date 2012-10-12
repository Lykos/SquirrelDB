module SquirrelDB

  module AST

    class TableCreator

      def initialize(variable, columns, schema_manager)
        @variable = variable
        @columns = columns
        @schema_manager = schema_manager
      end

      attr_reader :variable, :columns

      def to_s
        "TableCreator( #{@variable.to_s}, [ " + @columns.collect { |c| c.name.to_s + " " + c.type.to_s }.join(", ") + " ] )"
      end

      def inspect
        "TableCreator( #{@variable.inspect}, [ " + @columns.collect { |c| c.inspect }.join(", ") + " ] )"
      end

      def ==(other)
        super && @variable == other.variable && @columns == other.columns
      end
      
      def hash
        @hash ||= [super, @variable, @columns].hash
      end
      
      def query?
        false
      end
      
      def execute(state)
        @schema_manager.add(@variable, Schema::TableSchema.new(@columns))
      end

    end

  end

end
