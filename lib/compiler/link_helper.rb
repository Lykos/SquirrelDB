module SquirrelDB
  
  module Compiler
    
    module LinkHelper

      def each_link_info(names, schema, &block)
        Enumerator.new do |yielder|
          schema.each_column.with_index do |col, i|
            col_var = Variable.new(col.name)
            yielder.yield col_var, col, i
            names.each do |n|
              yielder.yield ScopedVariable.new(n, col_var), col, i
            end
          end
        end.each(&block)
      end
      
    end
    
  end
      
end