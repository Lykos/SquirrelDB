require 'server/crypto_socket'

module SquirrelDB

  # Client side of a secure socket
  module Client
  
    # +config+:: A hash table containing at least the key +:aliases+
    # +public_key_callback+:: A Proc object that takes a public key as input and returns
    #                         true if this key is accepted and false otherwise.
    class ClientSocket < Server::CryptoSocket
  
      def self.open(io, public_key_callback)
        lsio = new(io, public_key_callback)
        return lsio unless block_given?
        begin
          yield(lsio)
        ensure
          lsio.close unless lsio.closed?
        end
      end
  
      def initialize(io, public_key_callback)
        # Send Client hello
        packed_client_nonce = generate_packed_nonce
        io.syswrite(pack_version(VERSION))
        io.syswrite(packed_client_nonce)
  
        # Get signed Server hello
        packed_version = io.sysread(VERSION_BYTES)
        version = unpack_version(packed_version)
        raise IOError, "CryptoSockets with different versions cannot communicate." unless version == VERSION
        packed_server_nonce = io.sysread(NONCE_BYTES)
        public_key = internal_read(io)
        group = internal_read(io)
        server_part = internal_read(io)
  
        verifier = ElgamalVerifier.new(public_key)
        signature = io.sysread(verifier.signature_length)
        signed_message_parts = [packed_version +
                                packed_server_nonce +
                                pack_internal(public_key) +
                                pack_internal(group) +
                                pack_internal(server_part) +
                                signature]
        signed_message = signed_message_parts.join
        raise IOError, "Invalid public key received." unless public_key_callback.call(public_key)
        raise IOError, "Invalid signature for server hello." unless verifier.verify(signed_message)
  
        # Do DH Key exchange
        ke = DHKeyExchange.new
        ke.group = group
        ke.other_part = server_part
        io.syswrite(pack_internal(ke.own_part))
        secret = ke.key
  
        keys_states = generate_keys_states(secret, packed_client_nonce + packed_server_nonce.force_encoding(packed_client_nonce.encoding))
        super(io, keys_states)
      end
  
    end
  
  end

end
