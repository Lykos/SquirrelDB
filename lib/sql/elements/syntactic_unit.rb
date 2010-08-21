class String

   def underscore
     gsub(/::/, '/').
       gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
       gsub(/([a-z\d])([A-Z])/,'\1_\2').
       tr("-", "_").
       downcase
   end
   
end

 module Sql

  class SyntacticUnit

    def visit(visitor)
      visitor.send("visit_" + self.class.to_s.underscore, self)
    end

    def ==(other)
      self.class == other.class
    end

  end

end
