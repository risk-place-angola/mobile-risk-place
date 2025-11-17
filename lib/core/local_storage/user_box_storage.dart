import 'dart:developer' show log;

import 'package:hive/hive.dart';
import 'package:rpa/core/database_helper/database_helper.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/providers/repository_providers.dart';

abstract class IUserBox {
  Future<void> storeUser({required User user});
  Future<void> deleteUserInfo();
  Future<void> updateUser({required User user});
  Future<User?> getUser();
  Future<List<User>> getUsers({required User user});
}

class UserBox extends IUserBox {
  @override
  Future<void> deleteUserInfo() async {
    await Hive.openBox(BDCollections.USERS);
    await Hive.box(BDCollections.USERS).delete("user");
    
    // 🔑 Limpar token do AuthTokenManager
    log('Clearing auth token on user delete...', name: 'UserBox');
    AuthTokenManager().clearToken();
  }

  @override
  Future<User?> getUser() async {
    await Hive.openBox(BDCollections.USERS);
    final box = Hive.box(BDCollections.USERS);
    try {
      final result = await box.get("user") as Map<String, dynamic>?;
      if (result == null) return null;
      log(result.toString(), name: "UserBox - getUser()");

      final userData = AuthTokenResponseDTO.fromJson(result);
      
      // 🔑 Restaurar token no AuthTokenManager quando carregar usuário
      if (userData.accessToken.isNotEmpty) {
        log('Restoring auth token from storage...', name: 'UserBox');
        AuthTokenManager().setToken(userData.accessToken);
        log('Auth token restored successfully', name: 'UserBox');
      }
      
      return User(
        id: userData.user.id,
        name: userData.user.name,
        email: userData.user.email,
      );
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
  Future<void> storeUser({required User user}) async {
    await Hive.openBox(BDCollections.USERS);
    final box = Hive.box(BDCollections.USERS);
    return box.put("user", user.toJson());
  }

  @override
  Future<void> updateUser({required User user}) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }
}
