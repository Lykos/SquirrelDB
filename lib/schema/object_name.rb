module RubyDB
  
  module Schema

    class ObjectName

      def initialize( scopes, name )
        @scopes = scopes
        @name = name
      end

      attr_reader :scopes, :name
      
    end

  end
  
end
