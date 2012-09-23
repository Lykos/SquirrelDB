require 'sql/pre_parser'
require 'sql/lexical_parser'
require 'sql/syntactic_parser'
require 'sql/parser'

module SquirrelDB

  module SQL

    class ParserFactory

      def parser
        Parser.new( pre_parser, lexical_parser, syntactic_parser )
      end

      def pre_parser
        PreParser.new
      end

      def lexical_parser
        LexicalParser.new
      end

      def syntactic_parser
        SyntacticParser.new
      end
      
    end

  end
  
end
