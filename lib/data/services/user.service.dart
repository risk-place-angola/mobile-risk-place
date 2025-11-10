import 'dart:developer';

import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/core/utils/Utils.dart';
import 'package:rpa/data/models/user.model.dart';

abstract class IUserService {
  Future<bool> createUser({required User user});
  Future<void> updateUser({required User user});
  Future<void> deleteUser({required User user});
  Future<User?> getUser({required User user});
}

class UserService implements IUserService {
  final _db = DBHelper.instance;
  @override
  Future<bool> createUser({required User user}) async {
    try {
      log("Creating user: ${user.email}", name: "UserService");
      bool isSaved = false;

      var hashedPass = await Utils.hashPassword(user.password!);
      user.password = hashedPass;

      var data = await _db.database
          .child(BDCollections.USERS)
          .get()
          .then((v) => v.value as Map? ?? {});

      var users = data.values.map((e) => User.fromJson(e)).toList();
      for (var item in users) {
        if (user.email == item.email) {
          isSaved = true;
          return false;
        }
      }
      if (!isSaved) {
        await _db.setData(
            collection: BDCollections.USERS,
            value: user.isRFCE! ? user.toJsonIsRFCE() : user.toJson());
      }
      log("User created: ${user.email}", name: "UserService");
      return true;
    } catch (e) {
      log("Error creating user: $e", name: "UserService");
      return false;
    }
  }

  @override
  Future<void> deleteUser({required User user}) async {
    await _db.deleteData(collection: BDCollections.USERS, value: user.toJson());
  }

  @override
  Future<User?> getUser({required User user}) async {
    User? user0 = await _db.getData(
        collection: BDCollections.USERS, value: user.toJson());

    return user0;
  }

  @override
  Future<void> updateUser({required User user}) async {
    await _db.updateData(collection: BDCollections.USERS, value: user.toJson());
  }
}
