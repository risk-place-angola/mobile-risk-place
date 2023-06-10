import 'dart:developer';

import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/core/local_storage/user_box_storage.dart';
import 'package:rpa/core/storage_helper/storage_helper.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/sources/auth/remote_source.dart';

abstract class IAuthService {
  Future<User> login({required User user});
  Future<void> logout();
  Future<void> register({required User user});
  Future<void> resetPassword({required String email});
}

class AuthService implements IAuthService {
  final _source = AuthRemoteSource();
  @override
  Future<User> login({required User user}) async {
    final response = await _source.login(user: user);
    await UserBox().storeUser(user: user);
    return response;
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future register({required User user}) async {
    final response = await _source.register(user: user);
    await UserBox().storeUser(user: user);
    return response;
  }

  @override
  Future<void> resetPassword({required String email}) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }
}
