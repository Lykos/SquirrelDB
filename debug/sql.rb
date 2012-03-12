$:.unshift( 'lib' )

require 'sql/parser/syntactic_parser'
require 'sql/compiler/rel_alg_converter'

include RubyDB
include Sql

E = "5 * 3434 + 4 * (5 + 1)"
P = SyntacticParser.new
C = RelAlgConverter.new


