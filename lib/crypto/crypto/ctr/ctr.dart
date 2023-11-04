import 'package:blockchain_utils/crypto/crypto/blockcipher/blockcipher.dart';
import 'package:blockchain_utils/binary/binary_operation.dart';

/// Counter (CTR) mode for block ciphers.
///
/// The `CTR` class provides a counter mode of operation for block ciphers, which turns a block cipher into a
/// stream cipher. It uses a counter and an initialization vector (IV) to generate a stream of key material that is
/// XORed with the plaintext to produce the ciphertext. The class supports dynamic block sizes based on the
/// provided block cipher.
///
/// Properties:
/// - `_counter`: A byte array used as the counter value.
/// - `_buffer`: A buffer for storing the encrypted block.
/// - `_bufpos`: An internal variable tracking the buffer position.
/// - `_cipher`: The block cipher used for encryption.
///
/// Constructor:
/// - `CTR`: Initializes the CTR mode with the given block cipher and IV. It allocates space for the counter and
/// the encrypted block buffer and sets up the initial state.
///
/// Note: CTR mode effectively converts a block cipher into a stream cipher by generating a keystream. It is used
/// for encrypting data with a block cipher in a parallelizable manner. Ensure that the IV is unique for each message.
class CTR {
  /// Counter value
  late final List<int> _counter;

  /// Encrypted block buffer
  late final List<int> _buffer;

  /// Buffer position
  int _bufpos = 0;

  /// Block cipher for encryption
  BlockCipher? _cipher;

  /// Returns the block size of the block cipher, or null if not set.
  int? get blockSize => _cipher?.blockSize;

  /// Creates a CTR instance with the given block cipher and initialization vector (IV).
  ///
  /// Parameters:
  /// - `cipher`: The block cipher used for encryption.
  /// - `iv`: The initialization vector for the CTR mode.
  CTR(BlockCipher cipher, List<int> iv) {
    _counter = List<int>.filled(cipher.blockSize, 0);

    _buffer = List<int>.filled(cipher.blockSize, 0);
    setCipher(cipher, iv);
  }

  /// Sets the block cipher and initialization vector (IV) for the Counter (CTR) mode.
  ///
  /// This method allows you to specify the block cipher and IV to be used for the CTR mode. It performs
  /// necessary validation and setup for encryption. If the provided IV is not null, it copies the IV to
  /// the internal counter, overwriting its current value.
  ///
  /// Parameters:
  /// - `cipher`: The block cipher to be used for encryption.
  /// - `iv`: The initialization vector (IV) for the CTR mode.
  ///
  /// Throws:
  /// - `ArgumentError` if the IV length is not equal to the block size of the cipher.
  ///
  /// Returns:
  /// - The updated CTR instance after setting the cipher and IV.
  ///
  /// Note: It's important to use a unique IV for each message to ensure security and prevent potential
  /// vulnerabilities in the CTR mode.
  CTR setCipher(BlockCipher cipher, List<int>? iv) {
    _cipher = null;

    if (iv != null && iv.length != _counter.length) {
      throw ArgumentError("CTR: iv length must be equal to cipher block size");
    }
    _cipher = cipher;

    if (iv != null) {
      _counter.setAll(0, iv);
    }
    _bufpos = _buffer.length;
    return this;
  }

  /// Clears internal state and data in the Counter (CTR) mode instance for security and memory management.
  ///
  /// This method securely zeros the internal encrypted block buffer, the counter, and resets the buffer
  /// position and cipher reference to their initial states. It is essential for maintaining the security
  /// of the CTR mode instance after use and ensuring that no sensitive data remains in memory.
  ///
  /// Returns:
  /// - The same CTR instance after cleaning for method chaining.
  ///
  /// Note: Properly cleaning the CTR mode instance is crucial for security and memory management to
  /// prevent potential data leaks.
  CTR clean() {
    zero(_buffer); // Securely zero the encrypted block buffer
    zero(_counter); // Securely zero the counter
    _bufpos = _buffer.length; // Reset the buffer position
    _cipher = null; // Clear the cipher reference
    return this;
  }

  void _fillBuffer() {
    _cipher!.encryptBlock(_counter, _buffer);
    _bufpos = 0;
    _incrementCounter(_counter);
  }

  /// XORs source data with the keystream and writes the result to the destination.
  ///
  /// This method XORs the bytes from the source `List<int>` with the keystream generated by the Counter (CTR)
  /// mode and writes the result to the destination `List<int>`. It ensures that the keystream is continuously
  /// generated as needed, filling the buffer when it's exhausted.
  ///
  /// Parameters:
  /// - `src`: The source data to be XORed with the keystream.
  /// - `dst`: The destination `List<int>` where the XORed result will be written.
  ///
  /// Note: This method effectively applies the CTR mode encryption by XORing the source data with the keystream,
  /// allowing for secure encryption of data.
  void streamXOR(List<int> src, List<int> dst) {
    for (var i = 0; i < src.length; i++) {
      if (_bufpos == _buffer.length) {
        _fillBuffer();
      }
      dst[i] = (src[i] & mask8) ^ _buffer[_bufpos++];
    }
  }

  /// Generates and writes keystream to the destination.
  ///
  /// This method generates a stream of keystream bytes and writes them to the destination `List<int>`.
  /// The keystream is continuously generated as needed, with the option to specify whether it is intended
  /// for encryption or decryption.
  ///
  /// Parameters:
  /// - `dst`: The destination `List<int>` where the generated keystream will be written.
  /// - `forEncryption`: A boolean flag indicating whether the keystream is intended for encryption. If set
  ///   to `true`, the keystream is used for encryption; if set to `false`, it is used for decryption.
  ///
  /// Note: This method is essential for generating the keystream needed for encryption or decryption in the
  /// Counter (CTR) mode.
  void stream(List<int> dst) {
    for (var i = 0; i < dst.length; i++) {
      if (_bufpos == _buffer.length) {
        _fillBuffer();
      }
      dst[i] = _buffer[_bufpos++];
    }
  }
}

void _incrementCounter(List<int> counter) {
  var carry = 1;
  for (var i = counter.length - 1; i >= 0; i--) {
    carry = carry + (counter[i] & mask8);
    counter[i] = carry & mask8;
    carry >>= 8;
  }
  if (carry > 0) {
    throw ArgumentError("CTR: counter overflow");
  }
}
