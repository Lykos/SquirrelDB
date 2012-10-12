module SquirrelDB
  
  module Compiler
    
    module LinkHelper

      def each_link_info(names, schema)
        Enumerator do |yielder|
          schema.each_column do |col|
            yielder.yield Variable.new(col.name), col
            names.each do |n|
              yielder.yield ScopedVariable.new(n, col_var), col
            end
          end
        end.each(&block)
      end
      
    end
    
  end
      
end