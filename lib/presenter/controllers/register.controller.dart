import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/client_helper/client_helper.dart';
import 'package:rpa/core/local_storage/user_box_storage.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/sources/auth/remote_source.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';

mixin RegisterState implements ChangeNotifier {
  bool imRFCE = false;
  bool isLoading = false;

  setLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  setRFCE(bool value) {
    imRFCE = value;
    notifyListeners();
  }
}

class RegisterController extends ChangeNotifier with RegisterState {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void register(BuildContext context) async {
    final _userService = AuthRemoteSource(client: HTTPClient());
    User _user = User(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      password: passwordController.text.trim(),
      isRFCE: imRFCE,
    );

    var saved = await _userService.register(user: _user);

    if (saved is User) {
      UserBox().storeUser(user: saved);
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

final registerControllerProvider = ChangeNotifierProvider((ref) {
  return RegisterController();
});
