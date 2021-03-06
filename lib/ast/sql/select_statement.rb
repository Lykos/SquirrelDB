require 'ast/common/element'

module SquirrelDB

  module AST

    class SelectStatement < Element

      def initialize(select_clause, from_clause, where_clause)
        @select_clause = select_clause
        @from_clause = from_clause
        @where_clause = where_clause
      end

      attr_reader :select_clause, :from_clause, :where_clause

      def to_s
        @select_clause.to_s + " " + @from_clause.to_s + " " + @where_clause.to_s
      end

      def inspect
        "SelectStatement( " + @select_clause.inspect + ", " +
          @from_clause.inspect + ", " + @where_clause.inspect + " )"
      end

      def ==(other)
        super && @select_clause == other.select_clause && @from_clause == other.from_clause && @where_clause == other.where_clause
      end
      
      def hash
        @hash ||= [super, @other].hash
      end
      
      def length
        @length ||= select_clause.length
      end
      
      def types
        @types ||= select_clause.types
      end

    end

  end

end
