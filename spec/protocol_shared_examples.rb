require 'server/protocol'
require 'errors/encoding_error'

include SquirrelDB::Server::Protocol

shared_examples "protocols" do |protocol_class|
  
  before :each do
    @p = protocol_class.new
    @version_string23 = "\x00\x23".force_encoding(Encoding::BINARY)
    @length_string = "\x00\x00\x00\x00\x00\x00\x00\x23".force_encoding(Encoding::BINARY)
    @internal_length_string = "\x00\x00\x00\x23".force_encoding(Encoding::BINARY)
  end

  it "should generate a nonce of the right length" do
    @p.generate_nonce.length.should eq(NONCE_BYTES)
  end
  
  it "should consider equal versions as compatible" do
    @p.versions_compatible(2, 2).should be_true
  end
  
  it "should consider different versions as incompatible" do
    @p.versions_compatible(2, 3).should be_false
  end
  
  it "should encode the version as a String of the right length" do
    @p.pack_version(0x23).length.should eq(VERSION_BYTES)
  end
  
  it "should encode the version as an ASCII 8 Bit String" do
    @p.pack_version(0x23).should be_binary_encoded
  end
  
  it "should encode the version correctly" do
    @p.pack_version(0x23).should eq(@version_string23)
  end

  it "should decode the version correctly" do
    @p.unpack_version(@version_string23).should eq(0x23)
  end
  
  it "should raise an error if the encoded version doesn't have ASCII 8 Bit encoding" do
    lambda { @p.unpack_version(@version_string23.force_encoding(Encoding::UTF_8)) }.should raise_error(SquirrelDB::EncodingError)
  end
  
  it "should encode the length as a String of the right length" do
    @p.pack_length(0x23).length.should eq(MESSAGE_LENGTH_BYTES)
  end
  
  it "should encode the length as an ASCII 8 Bit String" do
    @p.pack_length(0x23).should be_binary_encoded
  end
  
  it "should encode the length correctly" do
    @p.pack_length(0x23).should eq(@length_string)
  end

  it "should decode the length correctly" do
    @p.unpack_length(@length_string).should eq(0x23)
  end
  
  it "should raise an error if the encoded length doesn't have ASCII 8 Bit encoding" do
    lambda { @p.unpack_length(@length_string.force_encoding(Encoding::UTF_8)) }.should raise_error(SquirrelDB::EncodingError)
  end
  
  it "should encode the internal_length as a String of the right length" do
    @p.pack_internal_length(0x23).length.should eq(INTERNAL_LENGTH_BYTES)
  end
  
  it "should encode the internal_length as an ASCII 8 Bit String" do
    @p.pack_internal_length(0x23).should be_binary_encoded
  end
  
  it "should encode the internal_length correctly" do
    @p.pack_internal_length(0x23).should eq(@internal_length_string)
  end

  it "should decode the internal_length correctly" do
    @p.unpack_internal_length(@internal_length_string).should eq(0x23)
  end
  
  it "should raise an error if the encoded internal_length doesn't have ASCII 8 Bit encoding" do
    lambda { @p.unpack_internal_length(@internal_length_string.force_encoding(Encoding::UTF_8)) }.should raise_error(SquirrelDB::EncodingError)
  end
  
  it "should encode an internal message as an ASCII 8 Bit String" do
    @p.pack_internal("a".force_encoding(Encoding::UTF_8)).encoding.should be(Encoding::BINARY)
  end
  
  it "should encode an internal message correctly" do
    @p.pack_internal("a".force_encoding(Encoding::UTF_8)).should eq("\x00\x00\x00\x01a".force_encoding(Encoding::BINARY))
  end

  it "should encode an internal message with non-ASCII characters correctly" do
    @p.pack_internal("\u{263a}".force_encoding(Encoding::UTF_8)).should eq("\x00\x00\x00\x03\u{263a}".force_encoding(Encoding::BINARY))
  end
  
  it "should raise an error if an encoded internal message doesn't have ASCII 8 Bit encoding" do
    lambda { @p.read_internal("a".force_encoding(Encoding::UTF_8)) }.should raise_error(SquirrelDB::EncodingError)
  end
  
  it "should return nil if an internal message is too short to include the length" do
    @p.read_internal("a".force_encoding(Encoding::BINARY)).should be_nil
  end
  
  it "should return nil if an internal message is too short" do
    @p.read_internal("\x00\x00\x00\x02a".force_encoding(Encoding::BINARY)).should be_nil
  end
  
  it "should decode a complete internal message correctly" do
    @p.read_internal("\x00\x00\x00\x02ab".force_encoding(Encoding::BINARY)).should eq(["ab", ""])
  end
  
  it "should decode a complete internal message correctly and return the remaining part as well" do
    @p.read_internal("\x00\x00\x00\x02abc".force_encoding(Encoding::BINARY)).should eq(["ab", "c"])
  end
  
end