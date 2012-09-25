module SquirrelDB

  module AST
    
    class Visitor
      
      def method_missing(name, *args)
        if name.to_s =~ /^visit_/
          raise RuntimeError, "Unknown visitor operation #{name}."
        else
          super
        end
      end
      
    end

  end
  
end