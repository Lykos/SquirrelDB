require 'ast/common/element'
require 'ast/common/constant'

module SquirrelDB

  module AST

    # Represents one column of the Schema
    class Column < Element

      def initialize(name, type, default=Constant::NULL)
        @name = name
        @type = type
        @default = default
      end

      attr_reader :name, :type, :default
      
      def inspect
        "Column( #{@name.to_s}:#{@type.to_s}#{has_default? ? " = " + @default.value.inspect : ""} )"
      end
      
      def has_default?
        @default.value != nil
      end
      
      def to_s
        "Column( #{@name.to_s}:#{@type.to_s}#{has_default? ? " = " + @default.value.to_s : ""} )"
      end
      
      def hash
        @hash ||= [super, @name, @type, @default].hash
      end
      
      def ==(other)
        super &&
        @name == other.name &&
        @type == other.type &&
        @default == other.default
      end
      
    end

  end

end
