import 'package:blockchain_utils/binary/utils.dart';
import 'package:blockchain_utils/cbor/utils/dynamic_bytes.dart';
import 'package:blockchain_utils/cbor/core/tags.dart';
import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/compare/compare.dart';

/// A class representing a CBOR (Concise Binary Object Representation) Set value.
class CborSetValue<T> implements CborObject {
  /// Constructor for creating a CborSetValue instance with the provided parameters.
  /// It accepts a set of all encodable cbor object and optional list of CBOR tags.
  CborSetValue(this.value, [this.tags = const []]);

  /// List of CBOR tags associated with the URL value.
  @override
  final List<int> tags;

  /// value as set
  @override
  final Set<T> value;

  /// Encode the value into CBOR bytes
  @override
  List<int> encode() {
    final bytes = CborBytesTracker();
    bytes.pushTags(tags.isEmpty ? [CborTags.set] : tags);
    bytes.pushInt(MajorTags.array, value.length);
    for (final v in value) {
      final obj = CborObject.fromDynamic(v);
      final encodeObj = obj.encode();
      bytes.pushBytes(encodeObj);
    }
    return bytes.toBytes();
  }

  /// Returns the string representation of the value.
  @override
  String toString() {
    return value.join(",");
  }

  /// Encode the value into CBOR bytes an then to hex
  @override
  String toCborHex() {
    return BytesUtils.toHexString(encode());
  }

  /// override equal operation
  @override
  operator ==(other) {
    if (other is! CborSetValue) return false;
    return iterableIsEqual(value, other.value) && bytesEqual(tags, other.tags);
  }

  /// override hashcode
  @override
  int get hashCode => value.hashCode;
}
