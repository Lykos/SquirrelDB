module SquirrelDB

  module SQL

    class PreParser

      def process( string )
        string.lines.collect do |line|
          line.gsub( /--.*?$/, '' )
        end.join( ' ' ).gsub( /\/\*.*?\*\//, ' ' )
      end

    end

  end
  
end
