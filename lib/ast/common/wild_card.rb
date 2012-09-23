require 'ast/common/element'

module SquirrelDB

  module AST

    class WildCard < Element

      def to_s
        '*'
      end

    end

  end

end
