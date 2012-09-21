class String

   def underscore
     split(/::/)[-1].
       gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
       gsub(/([a-z\d])([A-Z])/,'\1_\2').
       tr("-", "_").
       downcase
   end
   
end

module SquirrelDB

  module AST

    class Element

      def let_visit( visitor, *args )
        visitor.send( ( "visit_" + self.class.to_s.underscore ).intern, *args )
      end

      def accept( visitor )
        let_visit( visitor, self )
      end

      def ==(other)
        self.class == other.class
      end

    end

  end

end
