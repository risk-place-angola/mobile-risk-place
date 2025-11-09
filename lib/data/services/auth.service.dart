import 'dart:developer';

import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/core/local_storage/user_box_storage.dart';
import 'package:rpa/data/models/user.model.dart';

abstract class IAuthService {
  Future<User> login({required User user});
  Future<void> logout();
  Future<bool> register({required User user});
  Future<void> resetPassword({required String email});
}

class AuthService implements IAuthService {
  final _db = DBHelper.instance;
  @override
  Future<User> login({required User user}) async {
    var _foundedUser;
    var data = await _db.database
        .child(BDCollections.USERS)
        .get()
        .then((v) => v.value as Map);

    for (var item in data.values) {
      if (user.email == item["email"]) {
        log("User Found");
        _foundedUser = User.fromJson(item);
        log(_foundedUser.toJsonIsRFCE().toString());

        UserBox().storeUser(user: _foundedUser);
      }
    }
    return _foundedUser ?? User();
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<bool> register({required User user}) async {
    try {
      await _db.setData(
          collection: BDCollections.USERS, value: user.toJson());
          return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  @override
  Future<void> resetPassword({required String email}) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }
}
