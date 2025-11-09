import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/services/user.service.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';
import 'package:uuid/uuid.dart';

mixin RegisterState implements ChangeNotifier {
  bool imRFCE = false;

  void setRFCE(bool value) {
    imRFCE = value;
    notifyListeners();
  }
}

class RegisterController extends ChangeNotifier with RegisterState {
  TextEditingController nameController =
      TextEditingController(text: 'Jorge Carlos');
  TextEditingController emailController =
      TextEditingController(text: 'paulinofonsecass@gmail.com');
  TextEditingController phoneController =
      TextEditingController(text: '987654321');
  TextEditingController passwordController =
      TextEditingController(text: 'password');

  void register(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    final isFormValid = _validateForm(name, email, phone, password);

    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Por favor, preencha todos os campos!",
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final userService = UserService();
    User user = User(
      id: Uuid().v4(),
      name: name,
      email: email,
      phoneNumber: phone,
      password: password,
      isRFCE: imRFCE,
      createdAt: DateTime.now(),
    );

    var saved = await userService.createUser(user: user);
    if (!context.mounted) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Erro ao registrar usuário!"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (saved) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
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

bool _validateForm(
  String name,
  String email,
  String phone,
  String password,
) {
  return name.isNotEmpty &&
      email.isNotEmpty &&
      phone.isNotEmpty &&
      password.isNotEmpty;
}

final registerControllerProvider = ChangeNotifierProvider((ref) {
  return RegisterController();
});
