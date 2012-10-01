require 'ast/common/element'
require 'schema/table_schema'

module SquirrelDB

  module AST

    class CreateTable < Element

      def initialize(variable, columns)
        @variable = variable
        @columns = columns
      end

      attr_reader :variable, :columns
      attr_writer :schema_manager

      def to_s
        "create table #{@variable.to_s} (" + @columns.collect { |c| c.name.to_s + " " + c.type.to_s }.join(", ") + ")"
      end

      def inspect
        "CreateTable_{#{@variable.inspect}}( " + @columns.collect { |c| c.inspect }.join(", ") + " )"
      end

      def ==(other)
        super && @variable == other.name && @columns == other.columns
      end
      
      def hash
        @hash ||= [super, @variable, @columns].hash
      end
      
      def query?
        false
      end
      
      def execute(state)
        raise "No schema manager set for #{inspect}." if @schema_manager.nil?
        @schema_manager.add(@variable, Schema::TableSchema.new(@columns))
      end

    end

  end

end
