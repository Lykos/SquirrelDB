require 'errors/connection_error'
require 'errors/communication_error'
require 'server/protocol'
require 'RubyCrypto'
require 'errors/encoding_error'

module SquirrelDB

  module Server
  
    class ServerProtocol
      
      include Protocol
      include Crypto
      
      # +signer+:: An object which can sign messages
      # +config+:: A hash table containing at least the keys +:public_key+, +:private_key+
      #            and +:dh_modulus_size+
      def initialize(signer, config)
        @signer = signer
        @config = config
      end
      
      # If there is enough data present, it reads the client hello from data which consists
      # of the version and the client nonce and returns true.
      # If the versions are not compatible, a +ConnectionError+ is thrown. 
      # If data is not long enough, it returns false and doesn't read anything.
      # After it has returned true once, it cannot be called again.
      # +data+:: String
      def read_client_hello(data)
        raise EncodingError, "data has not ASCII 8 Bit Encoding." unless data.encoding == Encoding::BINARY
        raise CommunicationError, "Client hello read twice." if @client_hello_read
        if data.length >= VERSION_BYTES
          client_version = unpack_version(data.byteslice(0, VERSION_BYTES))
          raise ConnectionError, "Server has version #{VERSION} and client has version #{version} which are not compatible." unless versions_compatible(VERSION, client_version)
          if data.length < VERSION_BYTES + NONCE_BYTES
            return false
          elsif data.length == VERSION_BYTES + NONCE_BYTES
            client_version = unpack_version(data.byteslice(0, VERSION_BYTES))
            @client_nonce = data.byteslice(VERSION_BYTES, NONCE_BYTES)
            @client_hello_read = true
          else
            raise ConnectionError, "Got #{data.length} bytes of data instead of #{VERSION_BYTES + NONCE_BYTES}."
          end
        else
          false
        end
      end
      
      # Generate the server hello as an ASCII 8 Bit String
      def server_hello
        hello_parts = [
          pack_version(VERSION),
          server_nonce,
          pack_internal(@config[:public_key]),
          pack_internal(group),
          pack_internal(server_dh_part)
        ].map { |c| c.force_encoding(Encoding::BINARY) }
        @signer.sign(hello_parts.join)
      end
      
      # If there is enough data present, it reads the client answer to the Diffie Hellman protocol and returns true.
      # Return nil if not enough data is present. Can only be called after the client hello has been read and can
      # only be called once successfully.
      # +data+:: ASCII 8 Bit String that represents the client part of the Diffie Hellman protocol.
      def read_client_dh_part(data)
        raise CommunicationError, "Read client Diffie Hellman part before client hello." unless @client_hello_read
        raise CommunicationError, "Client Diffie Hellman part read twice." if @client_dh_part_read
        raise ConnectionError, "Client Diffie Hellman part is not long enough to store the length." unless data.length >= INTERNAL_LENGTH_BYTES
        tmp = read_internal(data)
        return nil unless tmp
        raise ConnectionError, "Client Diffie Hellman part is too long." unless tmp[1].empty?
        dh.other_part = data
        secret = dh.key
        generate_crypto_objects(secret, @client_nonce + @server_nonce)
        @client_dh_part_read = true
      end
      
      private
      
      def server_dh_part
        @server_dh_part ||= dh.own_part
      end
      
      def server_nonce
        @server_nonce ||= generate_nonce
      end

      def dh
        @dh ||= DHKeyExchange.new
      end
      
      def group
        @group ||= dh.choose_group(@config[:dh_modulus_size])
      end
      
    end
    
  end
  
end