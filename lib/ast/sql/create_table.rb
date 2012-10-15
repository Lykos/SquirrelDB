require 'ast/common/element'
require 'schema/schema'

module SquirrelDB

  module AST

    class CreateTable < Element

      def initialize(variable, columns)
        @variable = variable
        @columns = columns
      end

      attr_reader :variable, :columns

      def to_s
        "create table #{@variable.to_s} (" + @columns.collect { |c| c.name.to_s + " " + c.type.to_s }.join(", ") + ")"
      end

      def inspect
        "CreateTable_{#{@variable.inspect}}( " + @columns.collect { |c| c.inspect }.join(", ") + " )"
      end

      def ==(other)
        super &&
        @variable == other.variable &&
        @columns == other.columns
      end
      
      def hash
        @hash ||= [super, @variable, @columns].hash
      end
      
    end

  end

end
