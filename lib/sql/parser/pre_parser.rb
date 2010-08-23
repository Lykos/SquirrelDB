module Sql

  class PreParser

    def parse( string )
      string.lines.collect do |line|
        lines.gsub( /--.*?$/, '' )
      end.join( ' ' ).gsub( /\/\*.*?\*\//, ' ' )
    end

  end
  
end
