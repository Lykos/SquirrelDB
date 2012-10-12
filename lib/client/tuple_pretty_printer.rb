module SquirrelDB
  
  module Client
    
    class TuplePrettyPrinter
      
      TUPLE_SEPARATOR = "\n"
      
      CELL_SEPARATOR = " " 
      
      def pretty_print(tuples)
        return "" if tuples.empty?
        tuples.map! { |t| t.map { |c| c.to_s } }
        lengths = (0...tuples[0].length).map { |i| tuples.map { |t| t[i].length }.max }
        tuples.map { |t| t.map.with_index { |c, i| c.to_s.ljust(lengths[i]) }.join(CELL_SEPARATOR) }.join(TUPLE_SEPARATOR)
      end
    
    end
    
  end
      
end
