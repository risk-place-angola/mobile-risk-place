import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rpa/core/local_storage/user_box_storage.dart';
import 'package:rpa/data/models/user.model.dart';

class AuthController extends ChangeNotifier {
  void initialize() async {
    setUser();
  }

  User? _userStored;

  User? get userStored => _userStored;

  logout() async {
    await UserBox().deleteUserInfo();
    _userStored = null;
    notifyListeners();
  }

  void setUser() async {
    _userStored = await UserBox().getUser() ?? User();
    notifyListeners();
  }
}

final authControllerProvider = ChangeNotifierProvider((ref) {
  return AuthController();
});
