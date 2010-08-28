require 'storage/page_accessor'
require 'storage/constants'

include Storage
include Constants

describe PageAccessor do

  before(:each) do
    fn = '/home/bernhard/Programmiertes/ruby/database/lib/storage/spec_bla'
    File.open( fn, 'w' ) do |f|
      f.puts( "\0" * PAGE_SIZE )
    end
    @page_accessor = PageAccessor.new( fn )
  end

  after(:each) do
    @page_accessor.close
  end

  it "should initially consist of zeros" do
    @page_accessor.get( 0 ).should == "\0" * PAGE_SIZE
  end

  it "should be equal to the thing we put there" do
    content = "add".ljust( PAGE_SIZE, "f" )
    @page_accessor.put( 0, content )
    @page_accessor.get( 0 ).should == content
  end

  it "should pad too short things" do
    content = "add"
    @page_accessor.put( 0, content )
    @page_accessor.get( 0 ).should == content.ljust( PAGE_SIZE, "\0" )
  end
=begin
  it "should raise an exception in case of too long content" do
    lambda { @pace_accessor.put( 0, "5" * (PAGE_SIZE + 1) ) }.should raise
  end
=end

end

