require 'ast/common/element'

module SquirrelDB

  module AST

    # Represents one column of the Schema
    class Column < Element

      def initialize(name, type, default=Constant.null(type))
        raise "Default for column #{name} has an invalid type #{default.type} instead of #{type}." unless default.type == type
        raise "Invalid column index #{index}." unless index.kind_of?(Integer) && index >= 0
        @name = name
        @type = type
        @default = default
      end

      attr_reader :name, :type, :default
      
      def inspect
        "Column_{#{@index}}( #{@name.inspect}:#{@type.to_s}#{has_default? ? " = " + @default.value.inspect : ""} )"
      end
      
      def has_default?
        @default.value != nil
      end
      
      def to_s
        @name.to_s
      end
      
      def hash
        @hash ||= [super, @name, @type, @default, @index].hash
      end
      
      def ==(other)
        super &&
        @name == other.name &&
        @type == other.type &&
        @default == other.default &&
        @index == other.index
      end
      
      def evaluate(state)
        state[@index]
      end
      
    end

  end

end
