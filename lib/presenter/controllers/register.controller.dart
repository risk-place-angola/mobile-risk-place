// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/services/user.service.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';
import 'package:uuid/uuid.dart';

class RegisterController extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void register(BuildContext context) async {
    final _userService = UserService();
    User _user = User(
      id: Uuid().v4(),
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      password: passwordController.text.trim(),
      createdAt: DateTime.now(),
    );
    var saved = await _userService.createUser(user: _user);
    if (saved) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Valide as credenciais por favor!"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

final registerControllerProvider = ChangeNotifierProvider((ref) {
  return RegisterController();
});
