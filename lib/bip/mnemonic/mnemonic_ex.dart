/// An exception representing an error related to the checksum validation of a mnemonic phrase.
///
/// This exception is thrown when the checksum of a mnemonic phrase is found to be invalid
/// during mnemonic validation or when attempting to derive a key from the mnemonic phrase.
class MnemonicChecksumError implements Exception {
  const MnemonicChecksumError([this.message]);

  final String? message;

  @override
  String toString() {
    return message ?? super.toString();
  }
}
