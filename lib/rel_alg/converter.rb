module SquirrelDB

  module RelAlg

    class Converter

      def initialize( verifier, pre_linker, rel_alg_converter, always_optimizer )
        @verifier = verifier
        @pre_linker = pre_linker
        @rel_alg_converter = rel_alg_converter
        @always_optimizer = always_optimizer
      end

      def process( statement )
        @verifier.process( statement )
        @always_optimizer.process( @rel_alg_converter.process( @pre_linker.process( statement ) ) )
      end
      
    end

  end
  
end
