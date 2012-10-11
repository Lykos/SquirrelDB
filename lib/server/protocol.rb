#encoding: UTF-8

require 'errors/encoding_error'
require 'RubyCrypto'

module SquirrelDB

  module Server
  
    module Protocol
      
      # Protocol version
      VERSION = 3
      
      # Number of bytes used to store the version
      VERSION_BYTES = 2
      
      # Length of the length of an internal message in bytes
      INTERNAL_LENGTH_BYTES = 4
      
      # Length of the length of a message
      MESSAGE_LENGTH_BYTES = 8
      
      # Length of the nonces in bytes
      NONCE_BYTES = 32
      
      # Bits in a byte
      BYTE_BITS = 8
      
      # Key length of the AES key in bits
      AES_KEY_LENGTH = 128
      
      # Key length of the AES Key in bytes
      KEY_BYTE_LENGTH = AES_KEY_LENGTH / BYTE_BITS
      
      # Size of one block of the AES encryption/decryption
      AES_BLOCK_SIZE = 16
      
      include Crypto
      attr_reader :crypto_objects_generated
      
      # Generate a nonce that consists of the date and some randomness as an ACII 8 Bit String.
      def generate_nonce
        time_part = [Time.now.to_i].pack("L").force_encoding(Encoding::BINARY)
        time_part + (time_part.length...NONCE_BYTES).map { [rand(1 << BYTE_BITS)].pack("C").force_encoding(Encoding::BINARY) }.join
      end
      
      # Tries to read an internal message preceded by its length. If packed_message
      # is not long enough, nothing is read and +nil+ is returned. If it is long enough,
      # the message and the rest of the packed_message are returned in a two element array.
      # +packed_message+:: An ASCII 8 bit string.
      def read_internal(packed_message)
        raise EncodingError if packed_message.encoding != Encoding::BINARY
        if packed_message.length < INTERNAL_LENGTH_BYTES
          nil
        else
          length = unpack_internal_length(packed_message.byteslice(0, INTERNAL_LENGTH_BYTES))
          if packed_message.length < INTERNAL_LENGTH_BYTES + length
            nil
          else
            [packed_message.byteslice(INTERNAL_LENGTH_BYTES, length), packed_message.byteslice(INTERNAL_LENGTH_BYTES + length..-1)]
          end
        end
      end
      
      # Encode an internal message and its length
      # +message+:: The message to be encoded
      def pack_internal(message)
        pack_internal_length(message.bytesize) + message.force_encoding(Encoding::BINARY)
      end

      # Checks if the versions can communicate
      # +server_version+:: A non-negative integer that represents the version of the server. 
      # +client_version+:: A non-negative integer that represents the version of the client. 
      def versions_compatible(server_version, client_version)
        server_version == client_version
      end
    
      # Encode the version in a two byte string
      # +version+:: The version to be encoded
      def pack_version(version)
        [version].pack("n").force_encoding(Encoding::BINARY)
      end
      
      # Extract the version from a two byte ASCII 8 Bit string
      # +packed_version+:: A two byte string that contains the version
      def unpack_version(packed_version)
        raise EncodingError, "packed_version has to be an ASCII 8 Bit String." unless packed_version.encoding == Encoding::BINARY
        packed_version.unpack("n")[0]
      end
      
      # Encode the length in an eight byte string
      # +length+:: The length to be encoded
      def pack_length(length)
        [length].pack("Q>").force_encoding(Encoding::BINARY)
      end
      
      # Extract the length from an eight byte ASCII 8 Bit string
      # +packed_length+:: An eight byte string that contains the length
      def unpack_length(packed_length)
        raise EncodingError, "packed_length has to be an ASCII 8 Bit String." unless packed_length.encoding == Encoding::BINARY
        packed_length.unpack("Q>")[0]
      end
      
      # Encode the length of an internal message in a four byte string
      # +length+:: The length to encode
      def pack_internal_length(length)
        [length].pack("L>").force_encoding(Encoding::BINARY)
      end
      
      # Extract the length of an internal message from a four byte ASCII 8 Bit string
      # +packed_length+:: A four byte string that contains the length
      def unpack_internal_length(packed_length)
        raise EncodingError, "packed_length has to be an ASCII 8 Bit String." unless packed_length.encoding == Encoding::BINARY
        packed_length.unpack("L>")[0]
      end
      
      # Generates keys from a given secret and initial states for the encryption
      # from given nonces and reates +@aes_encrypter+, +@aes_encrypter+, +@aes_signer+ and +@aes_verifier+
      # and initializes them with the generated keys and states.
      # Can only be called once per object.
      # +secret+:: A secret shared between both parties.
      # +nonces+:: Additional randomness shared between both parties.
      def generate_crypto_objects(secret, nonces)
        raise EncodingError, "Secret is not an ASCII 8 Bit String." unless secret.encoding == Encoding::BINARY
        raise EncodingError, "Nonces is not an ASCII 8 Bit String." unless nonces.encoding == Encoding::BINARY
        raise InternalConnectionError, "Generated crypto objects twice." if @crypto_objects_generated
        hasher = SHA2Hasher.new(2 * AES_KEY_LENGTH)
        
        keys = hasher.hash(secret + nonces)
        secrecy_key = keys[0...KEY_BYTE_LENGTH]
        authenticity_key = keys[KEY_BYTE_LENGTH...2 * KEY_BYTE_LENGTH]
        
        states = hasher.hash(nonces)
        secrecy_state = states[0...KEY_BYTE_LENGTH]
        authenticity_state = states[KEY_BYTE_LENGTH...2 * KEY_BYTE_LENGTH]
                
        @aes_encrypter = AESEncrypter.new(secrecy_key, secrecy_state)
        @aes_decrypter = AESDecrypter.new(secrecy_key, secrecy_state)
        @aes_signer = AESSigner.new(authenticity_key, authenticity_state)
        @aes_verifier = AESVerifier.new(authenticity_key, authenticity_state)
        @crypto_objects_generated = true
      end
      
      # Signs and encrypts a given UTF-8 String and returns an ASCII 8 Bit String with the encrypted data.
      # +data+:: The String to be encrypted.
      def sign_encrypt(data)
        raise InternalConnectionError, "Crypto objects have not been generated yet." unless @crypto_objects_generated
        raise EncodingError, "data has to be an UTF-8 Bit String." unless data.encoding == Encoding::UTF_8
        begin
          signed_message = @aes_signer.sign(data)
        rescue CryptoException => e
          raise InternalConnectionError, "Error while signing: #{e.message}"
        end
        begin
          encrypted_message = @aes_encrypter.encrypt(signed_message)
        rescue CryptoException => e
          raise InternalConnectionError, "Error while encrypting: #{e.message}"
        end
        pack_length(encrypted_message.length) + encrypted_message.force_encoding(Encoding::BINARY)
      end
      
      # Decrypts and verifies the given ASCII 8 Bit String. Returns nil if not enough data is present
      # and a two element Array consisting of the decrypted data as an UTF-8 String and the remaining data, if enough data
      # is present. A +ConnectionError+ is thrown if the verifier is not happy with the MAC or if the message has an invalid format.
      # +data+:: The signed and encrypted string.
      def decrypt_verify(data)
        raise InternalConnectionError, "Crypto objects have not been generated yet." unless @crypto_objects_generated
        raise EncodingError, "data has to be an ASCII 8 Bit String." unless data.encoding == Encoding::BINARY
        return nil if data.length < MESSAGE_LENGTH_BYTES
        length = unpack_length(data.byteslice(0, MESSAGE_LENGTH_BYTES))
        return nil if data.length < MESSAGE_LENGTH_BYTES + length
        raise ConnectionError, "The message is too short to include the MAC." if length <= AES_BLOCK_SIZE
        encrypted_message = data.byteslice(MESSAGE_LENGTH_BYTES, length)
        data = data.byteslice(MESSAGE_LENGTH_BYTES + length..-1)
        raise ConnectionError, "The message doesn't have a length that is divisible by the AES block size." unless encrypted_message.length % AES_BLOCK_SIZE == 0
        begin
          signed_message = @aes_decrypter.decrypt(encrypted_message)
        rescue CryptoException => e
          if e.message == "The padding of the message has an invalid format"
            raise ConnectionError, "The padding of the encrypted message has an invalid format."
          else
            raise InternalConnectionError, "Encrypted message was invalid: #{e.message}"
          end
        end
        begin
          raise ConnectionError, "Got invalid MAC." unless @aes_verifier.verify(signed_message)
        rescue CryptoException => e
          raise InternalConnectionError, "Error while verifying signature: #{e.message}"
        end
        begin
          [@aes_verifier.remove_signature(signed_message).force_encoding(Encoding::UTF_8), data]
        rescue CryptoException => e
          raise InternalConnectionError, "Error while removing signature: #{e.message}"
        end
      end
      
    end
    
  end
  
end