module SquirrelDB

  module SQL

    # Can remove comments from a string.
    class Preprocessor

      # Remove comments
      def process( string )
        string.lines.collect { |line| line.gsub( /--.*?$/, '' ) }.join( ' ' )
      end

    end

  end
  
end
