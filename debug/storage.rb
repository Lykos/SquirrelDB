$:.unshift( '../lib' )
require 'storage/tuple_accessor'
require 'storage/tuple_page'
require 'storage/page_accessor'
require 'storage/page_wrapper'
require 'storage/tuple_accessor'
require 'tid'
include SquirrelDB
include Storage
F = '/home/bernhard/Programs/ruby/SquirrelDB/try/bla'
PA = PageAccessor.new(F)
PW = TuplePageAccessor.new(PA, TuplePage)
TA = TupleAccessor.new(PW)
TP = TPA.get(0)
T0 = TID.new( 0, 0 )
T1 = TID.new( 0, 1 )
T2 = TID.new( 0, 2 )
T3 = TID.new( 0, 3 )
T4 = TID.new( 0, 4 )
TIDS = [T0, T1, T2, T3, T4]
