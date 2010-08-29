require 'storage/tuple_accessor'
require 'storage/page_wrapper'
require 'storage/page/tuple_page'
require 'storage/page_accessor'
require 'storage/exceptions/address_exception'
require 'tempfile'

include RubyDB::Storage
include Constants

describe TupleAccessor do

  before(:each) do
    f = Tempfile.new("tuple_accessor_spec_database")
    f.puts( "\0" * PAGE_SIZE )
    f.close
    @tuple_accessor = TupleAccessor.new( PageWrapper.new( PageAccessor.new( f.path ), TuplePage ) )
    @initial_tuples = ["ADD #{rand(100)}", "EEE #{rand(1000)}", "FGGG", "454"]
    @initial_tids = []
    @initial_tuples.each do |t|
      @initial_tids.push( @tuple_accessor.add_tuple( t ) )
    end
  end

  after(:each) do
    @tuple_accessor.close
  end

  it "should contain a tuple we added" do
    tuple = "add"
    tid = @tuple_accessor.add_tuple( tuple )
    @tuple_accessor.get( [tid] ).should == [tuple]
    @tuple_accessor.get_tuple( tid ).should == tuple
  end

  it "should contain the new version if we change a tuple" do
    tuple = "doof #{rand(100)}"
    @tuple_accessor.set_tuple( @initial_tids[1], tuple )
    @tuple_accessor.get( @initial_tids[1..1] ).should == [tuple]
    @tuple_accessor.get_tuple( @initial_tids[1] ).should == tuple
  end

  it "should contain the new versions if we change tuples" do
    tuples = ["doof #{rand(100)}", "dick #{rand(10)}"]
    @tuple_accessor.set( @initial_tids[1..2], tuples )
    @tuple_accessor.get( @initial_tids[1..2] ).should == tuples
    @tuple_accessor.get_tuple( @initial_tids[1] ).should == tuples[0]
    @tuple_accessor.get_tuple( @initial_tids[2] ).should == tuples[1]
  end

  it "should not change other tuples if we change a tuple" do
    tuple = "doof #{rand(100)}"
    @tuple_accessor.set_tuple( @initial_tids[1], tuple )
    @tuple_accessor.get( @initial_tids[0..0] + @initial_tids[2..3] ).should == @initial_tuples[0..0] + @initial_tuples[2..3]
    @tuple_accessor.get_tuple( @initial_tids[0] ).should == @initial_tuples[0]
    @tuple_accessor.get_tuple( @initial_tids[2] ).should == @initial_tuples[2]
    @tuple_accessor.get_tuple( @initial_tids[3] ).should == @initial_tuples[3]
  end

  it "should not change other tuples if we change tuples" do
    tuples = ["doof #{rand(100)}", "dick #{rand(10)}"]
    @tuple_accessor.set( @initial_tids[1..2], tuples )
    @tuple_accessor.get( [@initial_tids[0], @initial_tids[3]] ).should == [@initial_tuples[0], @initial_tuples[3]]
    @tuple_accessor.get_tuple( @initial_tids[0] ).should == @initial_tuples[0]
    @tuple_accessor.get_tuple( @initial_tids[3] ).should == @initial_tuples[3]
  end

  it "should not contain tuples we removed" do
    @tuple_accessor.remove( @initial_tids[1..2] )
    lambda { @tuple_accessor.get( @initial_tids[1..2] ) }.should raise_error AddressException
    lambda { @tuple_accessor.get_tuple( @initial_tids[1] ) }.should raise_error AddressException
    lambda { @tuple_accessor.get_tuple( @initial_tids[2] ) }.should raise_error AddressException
  end

  it "should not contain a tuple we removed" do
    @tuple_accessor.remove_tuple( @initial_tids[1] )
    lambda { @tuple_accessor.get( @initial_tids[1..1] ) }.should raise_error AddressException
    lambda { @tuple_accessor.get_tuple( @initial_tids[1] ) }.should raise_error AddressException
  end

  it "should still contain tuples we didn't remove (multiple removes)" do
    @tuple_accessor.remove( @initial_tids[1..2] )
    @tuple_accessor.get( [@initial_tids[0], @initial_tids[3]] ).should == [@initial_tuples[0], @initial_tuples[3]]
    @tuple_accessor.get_tuple( @initial_tids[0] ).should == @initial_tuples[0]
    @tuple_accessor.get_tuple( @initial_tids[3] ).should == @initial_tuples[3]
  end

  it "should still contain tuples we didn't remove (single remove)" do
    @tuple_accessor.remove_tuple( @initial_tids[1] )
    @tuple_accessor.get( @initial_tids[2..3] + @initial_tids[0..0] ).should == @initial_tuples[0..0] + @initial_tuples[2..3]
    @tuple_accessor.get_tuple( @initial_tids[0] ).should == @initial_tuples[0]
    @tuple_accessor.get_tuple( @initial_tids[2] ).should == @initial_tuples[2]
    @tuple_accessor.get_tuple( @initial_tids[3] ).should == @initial_tuples[3]
  end

end

