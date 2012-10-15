require 'ast/common/element'

module SquirrelDB

  module AST

    # Represents an expression that can have a type.
    class Expression < Element
      
      def initialize(type)
        @type = type
      end
      
      attr_reader :type
            
      def typed?
        @typed ||= !@type.nil?
      end
      
      def ==(other)
        super &&
        @type == other.type
      end
      
      def hash
        @hash ||= [super, @type].hash
      end
      
      private

      def type_string
        @type_string ||= typed? ? ":" + @type.to_s : ""
      end

    end

  end

end
