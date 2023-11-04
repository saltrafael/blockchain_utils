import 'package:blockchain_utils/crypto/crypto/hash/hash.dart';
import '../../quick_hex.dart';
import 'package:blockchain_utils/binary/utils.dart';
import 'package:test/test.dart';

import 'test_vector.dart';

void main() {
  test("sha512", () {
    for (final i in testVector) {
      final k = SHA512();
      final message = BytesUtils.fromHexString(i["message"]);
      k.update(message.sublist(0, 10));
      k.update(message.sublist(10));
      expect(k.digest().toHex(), i["hash"]);
      k.clean();
      k.update(message);
      expect(k.digest().toHex(), i["hash"]);
    }
  });
}
