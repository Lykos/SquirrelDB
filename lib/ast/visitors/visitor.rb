module SquirrelDB

  module AST
    
    class Visitor
      
      def visit(object, *args)
        send(("visit_" + underscore(object.class.to_s)).intern, *args)
      end
      
      def method_missing(name, *args)
        if name.to_s =~ /^visit_/
          raise RuntimeError, "Unknown visitor operation #{name}."
        else
          super
        end
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