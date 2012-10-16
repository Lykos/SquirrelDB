require 'ast/common/element'

module SquirrelDB

  module AST

    class SelectClause < Element

      def initialize( columns )
        @columns = columns
      end

      attr_reader :columns

      def ==(other)
        super && @columns == other.columns
      end
      
      def hash
        @hash ||= [super, @columns].hash
      end

      def to_s
        "select " + @columns.collect { |c| c.to_s }.join( ", " )
      end

      def inspect
        "SelectClause( " + @columns.collect { |c| c.inspect }.join( ", " ) + " )"
      end
      
      def length
        @length ||= columns.length
      end
      
      def types
        @types ||= columns.collect { |c| c.type }
      end

    end
    
    def select(*columns)
      SelectClause.new(columns)
    end

  end

end
