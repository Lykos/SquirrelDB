module SquirrelDB
  
  module Compiler
    
    module LinkHelper

      def each_link_info(names, schema, &block)
        Enumerator.new do |yielder|
          schema.each_column do |col|
            col_var = Variable.new(col.name)
            yielder.yield col_var, col
            names.each do |n|
              yielder.yield ScopedVariable.new(n, col_var), col
            end
          end
        end.each(&block)
      end
      
    end
    
  end
      
end