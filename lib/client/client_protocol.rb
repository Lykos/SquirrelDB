#encoding: UTF-8

require 'errors/connection_error'
require 'errors/internal_connection_error'
require 'server/protocol'
require 'RubyCrypto'
require 'errors/encoding_error'

module SquirrelDB

  module Client
  
    class ClientProtocol
      
      include Server::Protocol
      include Crypto
      
      attr_reader :public_key, :server_hello_read
      
      # Generate the client hello as an ASCII 8-Bit string
      def client_hello
        [
          pack_version(VERSION),
          client_nonce
        ].map { |c| c.force_encoding(Encoding::BINARY) }.join
      end
      
      # Read the server hello as an ASCII 8 Bit String. If not enough data is present, false is returned and nothing is read, if
      # enough data is present.
      # +data+:: ASCII 8 Bit String that encodes the version, the server nonce, the public key, the group and the server's part for
      #          the Diffie Hellman protocol.
      def read_server_hello(data)
        raise EncodingError, "data is not an ASCII 8 Bit String." unless data.encoding == Encoding::BINARY
        raise InternalConnectionError, "Server hello read twice." if @server_hello_read
        if data.length >= VERSION_BYTES
          client_version = unpack_version(data.byteslice(0, VERSION_BYTES))
          raise ConnectionError, "Server has version #{VERSION} and client has version #{client_version} which are not compatible." unless versions_compatible(VERSION, client_version)
          if data.length < VERSION_BYTES + NONCE_BYTES
            return false
          elsif data.length >= VERSION_BYTES + NONCE_BYTES
            server_nonce = data.byteslice(VERSION_BYTES, VERSION_BYTES + NONCE_BYTES)
            public_key, data2 = read_internal(data.byteslice(VERSION_BYTES + NONCE_BYTES..-1))
            return false unless data2
            group, data2 = read_internal(data2)
            return false unless data2
            server_dh_part, data2 = read_internal(data2)
            return false unless data2
            verifier = ElgamalVerifier.new(public_key)
            return false if verifier.signature_length > data2.length
            raise ConnectionError, "The signature has length #{data2.length} instead of #{verifier.signature_length}." unless data2.length == verifier.signature_length   
            raise ConnectionError, "Invalid signature received from server." if !verifier.verify(data)
            dh.group = group
            dh.other_part = server_dh_part
            secret = dh.key
            generate_crypto_objects(secret, client_nonce + server_nonce)
            @server_hello_read = true
          end
        else
          false
        end
      end
      
      # Return the client part for the Diffie Hellman protocol. Can only be called after the server part has been read.
      def client_dh_part
        raise InternalConnectionError, "Client Diffie Hellman part can only be generated after the server hello has been read." unless @server_hello_read
        @client_dh_part ||= dh.own_part
      end
      
      private
      
      def client_nonce
        @client_nonce ||= generate_nonce
      end

      def dh
        @dh ||= DHKeyExchange.new
      end
      
      def group
        @group ||= dh.choose_group
      end
      
    end
    
  end
  
end