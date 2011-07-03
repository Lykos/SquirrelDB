module RubyDB

  module Sql

    class Parser

      def initialize( pre_parser, lexical_parser, syntactic_parser )
        @pre_parser = pre_parser
        @lexical_parser = lexical_parser
        @syntactic_parser = syntactic_parser
      end

      def process( string )
        @syntactic_parser.process( @lexical_parser.process( @pre_parser.process( string ) ) )
      end
      
    end

  end

end
