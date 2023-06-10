import 'dart:developer';

import 'package:rpa/core/client_helper/client_helper.dart';
import 'package:rpa/data/models/user.model.dart';

abstract class IAuthRemoteSource {
  Future<User> login({required User user});
  Future register({required User user});
  Future<void> logout({required User user});
}

class AuthRemoteSource implements IAuthRemoteSource {
  final HTTPClient? client;
  AuthRemoteSource({this.client});
  @override
  Future<User> login({required User user}) async {
    final response =
        await client?.post(Endpoints.LOGIN, body: user.toLoginUser());
    return User.fromLogin(response);
  }

  @override
  Future<void> logout({required User user}) {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future register({required User user}) async {
    final response =
        await client?.post(Endpoints.REGISTER, body: user.registerUser());
    return User.fromJson(response);
  }
}
