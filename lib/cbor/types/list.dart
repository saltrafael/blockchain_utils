import 'package:blockchain_utils/binary/utils.dart';
import 'package:blockchain_utils/cbor/utils/dynamic_bytes.dart';
import 'package:blockchain_utils/cbor/core/tags.dart';
import 'package:blockchain_utils/cbor/core/cbor.dart';

/// A class representing a CBOR (Concise Binary Object Representation) List value.
class CborListValue<T> implements CborObject {
  /// Constructor for creating a CborListValue instance with the provided parameters.
  /// It accepts the List of all cbor encodable value and an optional list of CBOR tags.
  CborListValue.fixedLength(this.value, [this.tags = const []])
      : _isFixedLength = true;

  /// Constructor for creating a CborListValue instance with the provided parameters.
  /// It accepts the List of all cbor encodable value and an optional list of CBOR tags.
  /// this method encode values with indefinite tag.
  CborListValue.dynamicLength(this.value, [this.tags = const []])
      : _isFixedLength = false;

  /// List of CBOR tags associated with the URL value.
  @override
  final List<int> tags;

  /// value as List
  @override
  final List<T> value;

  final bool _isFixedLength;

  /// check is fixedLength or inifinitie
  bool get isFixedLength => _isFixedLength;

  /// Encode the value into CBOR bytes
  @override
  List<int> encode() {
    final bytes = CborBytesTracker();
    bytes.pushTags(tags);
    if (isFixedLength) {
      bytes.pushInt(MajorTags.array, value.length);
    } else {
      bytes.pushIndefinite(MajorTags.array);
    }
    for (final v in value) {
      final obj = CborObject.fromDynamic(v);
      final encodeObj = obj.encode();
      bytes.pushBytes(encodeObj);
    }
    if (!isFixedLength) {
      bytes.breakDynamic();
    }
    return bytes.toBytes();
  }

  /// Encode the value into CBOR bytes an then to hex
  @override
  String toCborHex() {
    return BytesUtils.toHexString(encode());
  }

  /// Returns the string representation of the value.
  @override
  String toString() {
    return value.join(",");
  }
}