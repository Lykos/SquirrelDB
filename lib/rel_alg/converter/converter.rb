module RubyDB

  module RelAlg

    class Converter

      def initialize( verifier, rel_alg_converter, always_optimizer )
        @verifier = verifier
        @rel_alg_converter = rel_alg_converter
        @always_optimizer = always_optimizer
      end

      def process( statement )
        @verifier.process( statement )
        @always_optimizer.process( @rel_alg_converter.process( statement ) )
      end
      
    end

  end
  
end
