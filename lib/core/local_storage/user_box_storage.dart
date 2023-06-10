import 'package:hive/hive.dart';
import 'package:rpa/core/local_storage/hive_config.dart';
import 'package:rpa/data/models/user.model.dart';

abstract class IUserBox {
  Future<void> storeUser({required User user});
  Future<void> deleteUserInfo();
  Future<void> updateUser({required User user});
  Future<User> getUser();
  Future<List<User>> getUsers({required User user});
}

class UserBox extends IUserBox {
  @override
  Future<void> deleteUserInfo() async {
    await Hive.box(HiveBoxs.USERBOX).delete("user");
  }

  @override
  Future<User> getUser() async {
    final box = Hive.box(HiveBoxs.USERBOX);
    try {
      return await box.get("user");
    } catch (e) {
      return User();
    }
  }

  @override
  Future<List<User>> getUsers({required User user}) {
    // TODO: implement getUsers
    throw UnimplementedError();
  }

  @override
  Future<void> storeUser({required User user}) {
    final box = Hive.box(HiveBoxs.USERBOX);
    return box.put("user", user);
  }

  @override
  Future<void> updateUser({required User user}) async {}
}
