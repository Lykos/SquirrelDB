$:.unshift('lib', 'lib/sql', 'lib/sql/elements', 'lib/sql/parser', 'lib/sql/compiler')

require 'rel_alg_converter'

include Sql

E = "5 * 3434 + 4 * (5 + 1)"
R = RelAlgConverter.new

