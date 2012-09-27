require 'ast/rel_alg_operators/join'
require 'ast/common/constant'
require 'schema/type'

module SquirrelDB

  module AST

    class Cartesian < Join

      def initialize( left, right )
        super( Constant.new( true, Type::BOOLEAN ), left, right )
      end
    end

  end
  
end
