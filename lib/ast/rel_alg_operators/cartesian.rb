require 'ast/rel_alg_operators/join'
require 'ast/common/constant'

module SquirrelDB

  module AST

    class Cartesian < Join
      
      def initialize( left, right )
        super( Constant::TRUE, left, right )
      end
      
      def inspect
        "Cartesian(#{@left.inspect}, #{@right.inspect})"
      end
      
      def to_s
        "Cartesian(#{@left.to_s}, #{@right.to_s})"
      end
      
    end

  end
  
end
