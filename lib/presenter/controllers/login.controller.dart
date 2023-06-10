// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/client_helper/client_helper.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/data/sources/auth/remote_source.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/pages/home_page/home.page.dart';

class LoginController extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  setLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void login(BuildContext context, WidgetRef ref) async {
    setLoading();
    notifyListeners();
    final _authService = AuthRemoteSource(client: HTTPClient());
    User _user = User(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    var saved = await _authService.login(user: _user);

    if (saved.token?.isNotEmpty ?? false) {
      ref.read(authControllerProvider).setUser();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Valide as credenciais por favor!"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    setLoading();
    notifyListeners();
  }
}

final loginControllerProvider = ChangeNotifierProvider((ref) {
  return LoginController();
});
