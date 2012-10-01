module SquirrelDB

  module SQL

    # Can remove comments from a string.
    class Preprocessor

      # Remove comments
      def process( string )
        string.lines.collect do |line|
          line.gsub( /--.*?$/, '' )
        end.join( ' ' ).gsub( /\/\*.*?\*\//, ' ' )
      end

    end

  end
  
end
