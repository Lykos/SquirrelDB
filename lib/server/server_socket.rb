require 'RubyCrypto'
require 'crypto/socket'

module Crypto

  class ServerSocket < Socket

    def self.open(io, public_key, private_key, dh_bits)
      lsio = new(io, public_key, private_key, dh_bits)
      return lsio unless block_given?
      begin
        yield(lsio)
      ensure
        lsio.close unless lsio.closed?
      end
    end

    def initialize(io, signer, public_key, dh_bits)
      # Get Client hello
      version = unpack_version(io.sysread(VERSION_BYTES))
      raise IOError, "CryptoSockets with different versions cannot communicate." unless version == VERSION
      packed_client_nonce = io.sysread(NONCE_BYTES)

      # Send signed Server hello and start DH Key Exchange
      ke = DHKeyExchange.new
      group = ke.choose_group(dh_bits)
      server_part = ke.own_part
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
      ke.other_part = internal_read(io)
      secret = ke.key

      keys_states = generate_keys_states(secret, packed_client_nonce + packed_server_nonce.force_encoding(packed_client_nonce.encoding))
      super(io, keys_states)
    end

  end

end