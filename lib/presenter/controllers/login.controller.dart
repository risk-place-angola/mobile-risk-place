import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/pages/home_page/home.page.dart';

class LoginController extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context, WidgetRef ref) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authService = ref.read(authServiceProvider);

    final loginRequester = LoginRequestDTO(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    var userSaved = await authService.login(user: loginRequester);

    if (!context.mounted) {
      log("context not mounted");
      return;
    }

    if (userSaved != null) {
      ref.read(authControllerProvider).updateUser();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
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
