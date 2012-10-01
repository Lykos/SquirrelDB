require 'sql/preprocessor'
require 'sql/lexical_parser'
require 'sql/syntactic_parser'
require 'sql/parser'

module SquirrelDB

  module SQL

    class ParserFactory

      def parser
        Parser.new(preprocessor, lexical_parser, syntactic_parser)
      end

      def preprocessor
        @preprocessor ||= Preprocessor.new
      end

      def lexical_parser
        @lexical_parser ||= LexicalParser.new
      end

      def syntactic_parser
        @syntactic_parser ||= SyntacticParser.new
      end
      
    end

  end
  
end
