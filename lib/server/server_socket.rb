require 'RubyCrypto'
require 'server/crypto_socket'

module SquirrelDB
  
  module Server
    
    # Server side socket for a secure connection to a particular client.
    class ServerSocket < CryptoSocket
      
      # Opens a new +ServerSocket+.
      # +io+:: The duplex IO object (usually a socket) the server socket is based upon
      # +signer+:: An object that is able to sign messages.
      # +crypto_info+:: A hash table containing a binary string +public_key+ and the
      # If a block is given, the server_socket is yielded in this block and closed
      # automatically after the execution of this block.
      def self.open(io, signer, crypto_info)
        socket = new(io, signer, crypto_info)
        return socket unless block_given?
        begin
          yield(lsio)
        ensure
          socket.close unless socket.closed?
        end
        socket
      end
  
      protected
      
      # Opens a new connection.
      # +io+:: The io object (usually a socket) the server socket is based upon
      # +signer+:: An object that is able to sign messages.
      # +crypto_info+:: A hash table containing a binary string +public_key+ and the
      #                 number of bits used for Diffie Hellman +dh_bits+.
      def initialize(io, signer, crypto_info)
        # Get Client hello
        version = unpack_version(io.sysread(VERSION_BYTES))
        raise IOError, "CryptoSockets with different versions cannot communicate." unless version == VERSION
        packed_client_nonce = io.sysread(NONCE_BYTES)
  
        # Send signed Server hello and start DH Key Exchange
        key_info = DHKeyExchange.new
        group = key_info.choose_group(crypto_info[:dh_bits])
        server_part = key_info.own_part
        packed_server_nonce = generate_packed_nonce
        packed_message_parts = [pack_version(VERSION),
          packed_server_nonce,
          pack_internal(public_key),
          pack_internal(group),
          pack_internal(server_part)]
        packed_message = packed_message_parts.collect {|e| e.force_encoding("".encoding)}.join
        signed_packed_message = signer.sign(packed_message)
        io.syswrite(signed_packed_message)
  
        # Get DH Answer and generate key
        key_info.other_part = internal_read(io)
        secret = key_info.key
  
        keys_states = generate_keys_states(secret, packed_client_nonce + packed_server_nonce.force_encoding(packed_client_nonce.encoding))
        super(io, keys_states)
      end

    end
      
  end

end
