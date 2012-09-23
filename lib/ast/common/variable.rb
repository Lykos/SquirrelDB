require 'ast/common/element'

module SquirrelDB

  module AST

    class Variable < Element

      def initialize( name )
        @name = name
      end

      attr_reader :name

      def to_s
        @name
      end

      def inspect
        @name
      end

      def ==(other)
        super && @name == other.name
      end

      def visit( visitor )
        let_visit( visitor, @name )
      end
      
      def to_s
        @name
      end
      
      def inspect
        "Variable(" + @name + ")"
      end
      
      def accept( visitor )
        let_visit( visitor, @name )
      end

    end

  end

end
