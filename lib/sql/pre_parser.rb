module SquirrelDB

  module SQL

    class PreParser

      # Remove comments
      #
      def process( string )
        string.lines.collect do |line|
          line.gsub( /--.*?$/, '' )
        end.join( ' ' ).gsub( /\/\*.*?\*\//, ' ' )
      end

    end

  end
  
end
