require 'ast/common/element'
require 'schema/table_schema'

module SquirrelDB

  module AST

    class Insert < Element

      def initialize(variable, columns, inner)
        @variable = variable
        @columns = columns
        @inner = inner
      end

      attr_reader :variable, :columns, :inner
      attr_writer :schema_manager
      
      def to_s
        "insert into #{variable.to_s} ( #{columns.collect { |c| c.name }.join(", ")} ) #{inner.to_s}"
      end
      
      def inspect
        "Insert( #{variable.inspect}, ( #{columns.collect { |c| c.inspect }.join(", ")} ), #{inner.inspect} )"
      end
            
      def ==(other)
        super && @variable == other.name && @columns == other.columns && @inner == other.inner
      end
      
      def hash
        @hash ||= [super, @variable, @columns, @inner].hash
      end

    end

  end

end
