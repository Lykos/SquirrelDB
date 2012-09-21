require 'rel_alg/elements/join'
require 'schema/type'

module SquirrelDB

  module RelAlg

    class Cartesian < Join

      def initialize( left, right )
        super( Constant.new( true, Type::BOOLEAN ), left, right )
      end

      def accept( visitor )
        let_visit( visitor, @left.accept( visitor ), @right.accept( visitor ) )
      end

    end

  end
  
end
