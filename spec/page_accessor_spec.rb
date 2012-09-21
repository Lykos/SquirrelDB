require 'storage/page_accessor'
require 'storage/constants'
require 'storage/exceptions/format_exception'
require 'tempfile'

include SquirrelDB::Storage
include Constants

describe PageAccessor do

  before(:each) do
    @content = "\0" * PAGE_SIZE
    @content[19...23] = "sdad"
    f = Tempfile.new("tuple_accessor_spec_database")
    f.puts( @content )
    f.close
    @page_accessor = PageAccessor.new( f.path )
  end

  after(:each) do
    @page_accessor.close
  end

  it "should initially return the original content" do
    @page_accessor.get( 0 ).should == @content
  end

  it "should be equal to the thing we put there" do
    content = "add".ljust( PAGE_SIZE, "f" )
    @page_accessor.put( 0, content )
    @page_accessor.get( 0 ).should == content
  end

  it "should raise an exception in case of too short content" do
    lambda { @page_accessor.put( 0, "dd" ) }.should raise_error( FormatException )
  end

  it "should raise an exception in case of too long content" do
    lambda { @page_accessor.put( 0, "5" * (PAGE_SIZE + 1) ) }.should raise_error( FormatException )
  end

end

