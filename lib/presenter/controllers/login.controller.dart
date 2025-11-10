// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/pages/home_page/home.page.dart';

class LoginController extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  void login(BuildContext context, WidgetRef ref) async {
    final _authService = AuthService();
    User _user = User(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    var saved = await _authService.login(user: _user);

    if (saved.id != null) {
      ref.read(authControllerProvider).setUser();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
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

final loginControllerProvider = ChangeNotifierProvider((ref) {
  return LoginController();
});
