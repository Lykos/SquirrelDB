gem 'io-like'
require 'RubyCrypto'
require 'forwardable'
require 'io/like'

module RubyDB

  class CryptoSocket

    include IO::Like
    extend Forwardable

    VERSION = 2
    VERSION_BYTES = 1
    INTERNAL_LENGTH_BYTES = 4
    MESSAGE_LENGTH_BYTES = 8
    NONCE_BYTES = 32
    NONCE_RANDOM_WORDS = 7
    CHAR_BIT = 8
    AES_KEY_LENGTH = 128
    KEY_HEX_LENGTH = AES_KEY_LENGTH / CHAR_BIT

    def self.open(io, keys_states)
      lsio = new(io, keys_states)
      return lsio unless block_given?
      begin
        yield(lsio)
      ensure
        lsio.close unless lsio.closed?
      end
    end

    def initialize(io, keys_states)
      @io = io
      @aes_encrypter = AESEncrypter.new(keys_states[:secrecy_key], keys_states[:secrecy_state])
      @aes_decrypter = AESDecrypter.new(keys_states[:secrecy_key], keys_states[:secrecy_state])
      @aes_signer = AESSigner.new(keys_states[:authenticity_key], keys_states[:authenticity_state])
      @aes_verifier = AESVerifier.new(keys_states[:authenticity_key], keys_states[:authenticity_state])
      @in_buffer = ""
    end

    def_delegators :@io, :addr, :peeraddr

    def self.generate_keys_states(secret, nonces)
      keys_states = {}
      hasher = SHA2Hasher.new(2 * AES_KEY_LENGTH)
      keys = hasher.hash(secret + nonces)
      keys_states[:secrecy_key] = keys[0...KEY_HEX_LENGTH]
      keys_states[:authenticity_key] = keys[KEY_HEX_LENGTH...2 * KEY_HEX_LENGTH]
      states = hasher.hash(nonces)
      keys_states[:secrecy_state] = states[0...KEY_HEX_LENGTH]
      keys_states[:authenticity_state] = states[KEY_HEX_LENGTH...2 * KEY_HEX_LENGTH]
      keys_states
    end

    def generate_keys_states(secret, nonces)
      Socket.generate_keys_states(secret, nonces)
    end

    def fill_size
      0
    end

    def flush_size
      0
    end

    def sync
      true
    end

    def duplexed?
      true
    end

    private

    def unbuffered_read(length)
      while @in_buffer.length < length
        __crypto_socket_read_message
      end
      @in_buffer.slice!(0, length)
    end

    def unbuffered_write(string)
      begin
        signed_message = @aes_signer.sign(string)
      rescue CryptoException => e
        raise IOError, "Error while signing: #{e.message}"
      end
      begin
        encrypted_message = @aes_encrypter.encrypt(signed_message)
      rescue CryptoException => e
        raise IOError, "Error while encrypting: #{e.message}"
      end
      begin
        __crypto_socket_write(pack_length(encrypted_message.length) + encrypted_message)
      rescue IOError => e
        raise IOError, "Error writing to internal IO Object: #{e.message}"
      end
    end

    def __crypto_socket_read_message
      begin
        length = unpack_length(__crypto_socket_read(MESSAGE_LENGTH_BYTES))
        encrypted_message = __crypto_socket_read(length)
      rescue IOError => e
        raise IOError, "Error reading from internal IO Object: #{e.message}"
      end
      begin
        signed_message = @aes_decrypter.decrypt(encrypted_message)
      rescue CryptoException => e
        raise IOError, "Error while decrypting: #{e.message}"
      end
      begin
        raise IOError, "Got invalid MAC." unless @aes_verifier.verify(signed_message)
        message = @aes_verifier.remove_signature(signed_message)
        @in_buffer << message
      rescue CryptoException => e
        raise IOError, "Error while verifying signature: #{e.message}"
      end
    end

    def pack_version(version)
      [version].pack("C")
    end

    def unpack_version(packed_version)
      packed_version.unpack("C")[0]
    end

    def pack_length(length)
      [length].pack("Q>")
    end

    def unpack_length(packed_length)
      packed_length.unpack("Q>")[0]
    end

    def internal_pack_length(length)
      [length].pack("L>")
    end

    def internal_unpack_length(packed_length)
      packed_length.unpack("L>")[0]
    end

    def generate_packed_nonce
      ([Time.now.to_i] + (0..NONCE_RANDOM_WORDS).map { rand(1 << 32) }).pack("L8")
    end

    # Read an internal message directly from the io object using sysread
    #
    def internal_read(internal_io)
      length = internal_unpack_length(internal_io.sysread(INTERNAL_LENGTH_BYTES))
      internal_io.sysread(length)
    end

    def pack_internal(internal_message)
      internal_pack_length(internal_message.length) + internal_message
    end

    def __crypto_socket_read(length)
      @io.sysread(length)
    end

    def __crypto_socket_write(string)
      @io.syswrite(string)
    end

  end

end
