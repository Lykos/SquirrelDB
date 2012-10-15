require 'storage/raw_util'

include SquirrelDB::Storage
include RawUtil

describe RawUtil do

  it "extract_int should be left invertible" do
    string = "asdasfasdfasfasd".force_encoding(Encoding::BINARY)
    encode_int(extract_int(string), string.length).should eq(string)
  end
  
  it "encode_int should be left invertible, if a length, that is long enough is given" do
    int = 23423234234
    extract_int(encode_int(int, 20)).should == int
  end
  
  it "encode_int should be left invertible, if no length is given" do
    int = 23423234234
    extract_int(encode_int(int)).should == int
  end
  
  it "should raise an error if given a string of an encoding different from ASCII 8 Bit" do
    lambda { extract_int("asdf".force_encoding(Encoding::UTF_8)) }.should raise_error(SquirrelDB::EncodingError)
  end

  it "should turn binary strings to ints" do
    string = "\x01\x01\x00".force_encoding(Encoding::BINARY)
    extract_int(string).should eq(257)
  end

  it "should turn ints to binary strings of a fixed length if a length is given" do
    string = "\x01\x01\x00".force_encoding(Encoding::BINARY)
    encode_int(257, 3).should eq(string)
  end
  
  it "should raise an error in case of a negative integer" do
    lambda { encode_int(-1, 1) }.should raise_error(StorageError)
  end
  
  it "should raise an error if the integer is too large to be encoded in a string of the given length" do
    lambda { encode_int(256, 1) }.should raise_error(StorageError)
  end
  
  it "should be able to encode an integer of arbitrary length correctly, if no length is given" do
    string = "\x4f\x71\x02\x4b\x21\x7f\x35".force_encoding(Encoding::BINARY)
    encode_int(0x357f214b02714f).should eq(string)
  end
  
end
