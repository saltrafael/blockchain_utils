import 'package:blockchain_utils/bip/bip/bip49/bip49_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip49/bip49_coins.dart';
import 'package:blockchain_utils/binary/utils.dart';
import 'package:test/test.dart';
import 'test_vector.dart';

void main() {
  test("bip49", () {
    for (final i in testVector) {
      final seed = BytesUtils.fromHexString(i["seed"]);
      final coin = Bip49Coins.values.firstWhere((element) =>
          element.name.toLowerCase() ==
          (i["coin"] as String).replaceAll("_", "").toLowerCase());
      final b44 = Bip49.fromSeed(seed, coin);
      final coinInex = b44.purpose.coin;
      expect(b44.privateKey.toExtended, i["master"]);
      expect(b44.publicKey.toExtended, i["master_public"]);
      expect(coinInex.privateKey.toExtended, i["coin_private"]);
      expect(coinInex.publicKey.toExtended, i["coin_public"]);
      final accounts = (i["child"] as List);
      for (int i = 0; i < accounts.length; i++) {
        final accountInfo = accounts[i];
        final account = coinInex.account(i);
        expect(account.privateKey.toExtended, accountInfo["account"]);
        expect(account.publicKey.toExtended, accountInfo["account_public"]);
        expect(account.publicKey.toAddress, accountInfo["address"]);
      }
    }
  });
}
