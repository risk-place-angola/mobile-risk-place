import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/local_storage/user_box_storage.dart';
import 'package:rpa/data/models/user.model.dart';

class AuthController extends ChangeNotifier {
  void initialize() async {
    setUser();
    notifyListeners();
  }

  User? _userStored;

  User? get userStored => _userStored;

  logout() async {
    await UserBox().deleteUserInfo();
    _userStored = null;
    notifyListeners();
  }

  void setUser() async {
    _userStored = await UserBox().getUser();
    notifyListeners();
  }
}

final authControllerProvider = ChangeNotifierProvider((ref) {
  return AuthController();
});
