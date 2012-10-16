# encoding: UTF-8

require 'server/server_protocol'
require 'RubyCrypto'
require 'errors/encoding_error'
require 'errors/communication_error'
require 'server/protocol_shared_examples'
require 'spec_helper'

include SquirrelDB::Server
include Protocol
include Crypto

CONFIG = {:dh_modulus_size=>512, :public_key=>"\x00\x00\x00@\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC9\x0F\xDA\xA2!h\xC24\xC4\xC6b\x8B\x80\xDC\x1C\xD1)\x02N\b\x8Ag\xCCt\x02\v\xBE\xA6;\x13\x9B\"QJ\by\x8E4\x04\xDD\xEF\x95\x19\xB3\xCD:C\x9D\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\x01\x05\x00\x00\x00@$\x95i\xEF1=\x18\r~c\xDD\x8CHQ\xAE=\xFAD\xECI\x0F\x85\x01\x82S*`\xE4,\x9D\xB6\x84\xCB\xDE\xD0\x90q<\x86\xA9AGO%U-D\xB0\xC0\xC7\x04\x02\xA5\x19+\xE0FGOu\xF8\xB3\xD8\x11", :private_key=>"\u0000\u0000\u0000@\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC9\u000Fڢ!h\xC24\xC4\xC6b\x8B\x80\xDC\u001C\xD1)\u0002N\b\x8Ag\xCCt\u0002\v\xBE\xA6;\u0013\x9B\"QJ\by\x8E4\u0004\xDD\xEF\x95\u0019\xB3\xCD:C\x9D\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\u0000\u0000\u0000\u0001\u0005\u0000\u0000\u0000@Hxa\xB0E\u00197\xED\xCE:\xC9DI\xBE\x82\xC7\v\xA3\u001D\xB1\x86\eβ\u0011z\x88+\xBF\xDE\xFE5\xB7\x9Db\xFA\u0019\xC4ya\u0019\x88]}\xAA=r\x90\xF0\x9AD\x93\xFD\x8ABKo\u0019\x88\x95j\x9A\xEE\x9C"}
SIGNER = ElgamalSigner.new(CONFIG[:private_key])
  
class ServerProtocolDefault < ServerProtocol
  
  def initialize
    super(SIGNER, CONFIG)
  end
  
end

describe ServerProtocol do

  include_examples "protocols", ServerProtocolDefault
    
  before :each do
    @sp = ServerProtocolDefault.new
    @version_string = @sp.pack_version(VERSION)
    @client_hello = @version_string + "c\xC7$\xA0\xC1\xD7\x1F\".\x9A\xD0\x1C\xE2(W\x04A\xC1\xCE\x06N\x1F/\xA7\x9As\xD2\xD4\x87\xEF9\xA4".force_encoding(Encoding::BINARY)
  end
  
  it "should return false after reading a client hello that is too short to contain the version" do
    @sp.read_client_hello("".force_encoding(Encoding::BINARY)).should be_false
  end
  
  it "should return false after reading a client hello that is too short" do
    @sp.read_client_hello(@client_hello.byteslice(0, 5)).should be_false
  end

  it "should return true after reading a correct client hello" do
    @sp.read_client_hello(@client_hello).should be_true
  end

  it "should raise an exception after reading a client hello with an encoding different from ASCII 8 Bit" do
    lambda { @sp.read_client_hello("a".force_encoding(Encoding::UTF_8)) }.should raise_error(SquirrelDB::EncodingError)
  end

  it "should raise an exception after reading a second client_hello" do
    @sp.read_client_hello(@client_hello)
    lambda { @sp.read_client_hello(@client_hello) }.should raise_error(CommunicationError)
  end
  
  it "should return a server hello with an ASCII 8 Bit encoding" do
    @sp.server_hello.should be_binary_encoded
  end
  
  it "should return a server hello with the right signature" do
    ElgamalVerifier.new(CONFIG[:public_key]).verify(@sp.server_hello).should be_true
  end
  
end
