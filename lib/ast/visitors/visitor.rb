module SquirrelDB

  module AST
    
    module Visitor
      
      def visit(object, *args)
        send(("visit_" + underscore(object.class.to_s)).intern, object, *args)
      end
      
      private
   
      def underscore(string)
        string.split(/::/)[-1].
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end
            
    end

  end
  
end