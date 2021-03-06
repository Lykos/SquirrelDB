require 'ast/iterators/rel_alg_iterator' 
require 'data/state'
require 'schema/schema'
require 'data/tuple'

module SquirrelDB

  module AST

    class Projector < RelAlgIterator
      
      include Data

      def initialize(column_evaluators, inner)
        @column_evaluators = column_evaluators
        @inner = inner
      end

      attr_reader :column_evaluators, :inner
      
      def types
        @types ||= column_evaluators.collect { |ev| ev.type } 
      end
      
      def length
        @length ||= column_evaluators.length
      end
      
      def itopen(state)
        super
        inner.itopen(state)
      end
      
      def close
        super
        inner.close
      end
      
      def rewind
        super
        inner.rewind
      end
      
      def ==(other)
        super && @column_evaluators == other.column_evaluators && @inner == other.inner 
      end
      
      def hash
        @hash ||= [super, @column_evaluators, @inner].hash
      end
    
      def inspect
        "Projector_{" + @column_evaluators.collect { |ev| ev.inspect }.join(", ") + "}( #{@inner.inspect} )"
      end
      
      def to_s
        "Projector_{" + @column_evaluators.collect { |ev| ev.to_s }.join(", ") + "}( #{@inner.to_s} )"
      end

      def next_item
        super
        t = @inner.next_item
        return nil if t.nil?
        state = Data::State.new(t, @state)
        Tuple.new(
          @column_evaluators.collect do |ev|
            ev.evaluate( state )
          end
        )
      end
      
      def rewind
        super
        @inner.rewind
      end
      
    end

  end

end
