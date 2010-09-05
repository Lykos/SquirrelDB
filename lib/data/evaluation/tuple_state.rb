require 'data/evaluation/state'

module RubyDB
  
  module Data

    class TupleState < state

      def initialize( tuple )
        super
      end

      def []( name )
        tuple[name] || super
      end

      def []=( name, value )
        if tuple[name]
          tuple[name] = value
        else
          super
        end
      end
      
    end

  end
  
end
