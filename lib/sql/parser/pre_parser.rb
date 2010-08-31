module RubyDB

  module Sql

    class PreParser

      def parse( string )
        string.lines.collect do |line|
          line.gsub( /--.*?$/, '' )
        end.join( ' ' ).gsub( /\/\*.*?\*\//, ' ' )
      end

    end

  end
  
end
