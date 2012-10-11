require 'storage/raw_util'

include SquirrelDB::Storage
include RawUtil

describe RawUtil do

  it "should be invertible" do
    string = "asdasfasdfasfasd"
    encode_int( extract_int( string ), string.length ).should eq(string)
    int = 23423234234
    extract_int( encode_int( int, 20 ) ).should == int
  end

  it "should turn binary strings to ints" do
    string = "\1\1\0"
    extract_int( string ).should == 257
  end

  it "should turn ints to binary strings" do
    string = "\1\1\0"
    encode_int( 257, 3 ).should == string
  end
  
end

