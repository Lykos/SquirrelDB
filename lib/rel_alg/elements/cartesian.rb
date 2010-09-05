require 'sql/rel_alg/join'
require 'schema/type'

module RubyDB

  module RelAlg

    class Cartesian < Join

      def initialize( left, right )
        super( Constant.new( true, Type::BOOLEAN ), left, right )
      end

      def visit( visitor )
        let_visit( visitor, t )
      end

    end

  end
  
end
