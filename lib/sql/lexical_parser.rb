require 'sql/syntax'

module SquirrelDB

  module SQL

    class LexicalParser

      include Syntax

      def process( string )
        string.scan( TOKEN )
      end

    end
    
  end
  
end
