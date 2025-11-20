import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rpa/core/error/error_handler.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/services/user.service.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';
import 'package:uuid/uuid.dart';

mixin RegisterState implements ChangeNotifier {
  bool imRFCE = false;
  bool isLoading = false;

  void setRFCE(bool value) {
    imRFCE = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}

class RegisterController extends ChangeNotifier with RegisterState {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> register(BuildContext context, WidgetRef ref) async {
    setLoading(true);

    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();

      final userService = UserService();
      User user = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        phoneNumber: phone,
        password: password,
        isRFCE: imRFCE,
        createdAt: DateTime.now(),
      );

      var saved = await userService.createUser(user: user);

      if (!context.mounted) return;

      if (saved) {
        _showSuccessDialog(context);

        await Future.delayed(const Duration(milliseconds: 1500));

        if (!context.mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } else {
        _showSnackBar(
          context,
          "Erro ao registrar. Verifique suas credenciais.",
          isError: true,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    } finally {
      setLoading(false);
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Registro Concluído!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Você pode fazer login agora',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

final registerControllerProvider = ChangeNotifierProvider((ref) {
  return RegisterController();
});
