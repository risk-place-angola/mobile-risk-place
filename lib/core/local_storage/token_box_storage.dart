import 'package:hive_flutter/hive_flutter.dart';
import 'package:rpa/core/local_storage/hive_config.dart';

abstract class ITokenBox {
  Future<void> storeToken({required String token});
  Future<void> deleteToken();
  Future<String> getToken();
}

class TokenBox extends ITokenBox {
  @override
  Future<void> deleteToken() {
    // TODO: implement deleteToken
    throw UnimplementedError();
  }

  @override
  Future<String> getToken() async {
    var box = await Hive.openBox(HiveBoxs.TOKENBOX);
    try {
      return await box.get("token");
    } catch (e) {
      return "";
    }
  }

  @override
  Future<void> storeToken({required String token}) async {
    var box = await Hive.openBox(HiveBoxs.TOKENBOX);
    return box.put("token", token);
  }
}
