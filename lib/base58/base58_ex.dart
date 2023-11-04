/// An exception class representing an error related to Base58 checksum validation.
class Base58ChecksumError implements Exception {
  final String? message;

  /// Constructor for creating a Base58ChecksumError with an optional error message.
  const Base58ChecksumError([this.message]);

  @override
  String toString() {
    /// Provide a custom string representation of the error.
    return message ?? super.toString();
  }
}
