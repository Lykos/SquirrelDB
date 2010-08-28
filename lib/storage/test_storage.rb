require 'tuple_accessor'
include Storage
F = '/home/bernhard/Programmiertes/ruby/database/lib/storage/bla'
PA = PageAccessor.new(F)
TPA = TuplePageAccessor.new(PA)
TA = TupleAccessor.new(TPA)
TP = TPA.get(0)
T0 = TID.new( 0, 0 )
T1 = TID.new( 0, 1 )
T2 = TID.new( 0, 2 )
T3 = TID.new( 0, 3 )
T4 = TID.new( 0, 4 )
TIDS = [T0, T1, T2, T3, T4]
