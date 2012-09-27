module SquirrelDB

  module AST

    class Element

      def ==(other)
        self.class == other.class
      end

    end

  end

end
