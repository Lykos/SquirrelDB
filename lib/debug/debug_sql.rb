$:.unshift( 'lib' )

require 'sql/parser/syntactic_parser'

include RubyDB
include Sql

E = "5 * 3434 + 4 * (5 + 1)"
P = SyntacticParser.new

