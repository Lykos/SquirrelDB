require 'ast/common/element'

module SquirrelDB

  module AST

    class FromClause < Element

      def initialize( tables )
        @tables = tables
      end

      attr_reader :tables

      def to_s
        "from " + @tables.collect { |c| c.to_s }.join( ", " )
      end

      def inspect
        "FromClause( " + @tables.collect { |c| c.inspect }.join( ", " ) + " )"
      end

      def ==(other)
        super && @tables == other.tables
      end
      
      def hash
        @hash ||= [super, @tables].hash
      end

    end

  end

end
