require 'rel_alg/converter'
require 'rel_alg/rel_alg_converter'
require 'rel_alg/pre_linker'

module SquirrelDB

  module RelAlg

    class ConverterFactory

      def converter(table_manager, schema_manager)
        @converter ||= Converter.new( pre_linker(table_manager, schema_manager), rel_alg_converter )
      end
      
      def pre_linker(table_manager, schema_manager)
        @pre_linker ||= PreLinker.new(table_manager, schema_manager)
      end

      def rel_alg_converter
        @rel_alg_converter ||= RelAlgConverter.new
      end
      
    end

  end

end
