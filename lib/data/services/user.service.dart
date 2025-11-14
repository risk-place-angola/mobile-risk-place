import 'dart:developer';

import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/core/local_storage/hive_config.dart';
import 'package:rpa/core/utils/Utils.dart';
import 'package:rpa/data/models/user.model.dart';

abstract class IUserService {
  Future<bool> createUser({required User user});
  Future<void> updateUser({required User user});
  Future<void> deleteUser({required User user});
  Future<User?> getUser({required String email});
}

class UserService implements IUserService {
  final _db = DBHelper.instance;

  @override
  Future<bool> createUser({required User user}) async {
    try {
      log("Creating user: ${user.email}", name: "UserService");

      final existingUser = await getUser(email: user.email!);
      if (existingUser != null) {
        log("User already exists: ${user.email}", name: "UserService");
        return false;
      }

      var hashedPass = await Utils.hashPassword(user.password!);
      user.password = hashedPass;

      await _db.setData(
        boxName: HiveBoxs.USERBOX,
        key: user.email!,
        value: user,
      );

      log("User created: ${user.email}", name: "UserService");
      return true;
    } catch (e) {
      log("Error creating user: $e", name: "UserService");
      return false;
    }
  }

  @override
  Future<void> deleteUser({required User user}) async {
    await _db.deleteData(boxName: HiveBoxs.USERBOX, key: user.email!);
  }

  @override
  Future<User?> getUser({required String email}) async {
    final user = await _db.getData(boxName: HiveBoxs.USERBOX, key: email);
    return user as User?;
  }

  @override
  Future<void> updateUser({required User user}) async {
    await _db.updateData(
      boxName: HiveBoxs.USERBOX,
      key: user.email!,
      value: user,
    );
  }
}