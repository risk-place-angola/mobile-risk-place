import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/core/error/error_handler.dart';
import 'package:rpa/core/device/device_id_manager.dart';
import 'package:rpa/core/services/fcm_service.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/data/providers/user_provider.dart';
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/pages/home_page/home.page.dart';
import 'package:rpa/presenter/pages/auth/verification_code_page.dart';

class LoginController extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void reset() {
    emailController.clear();
    passwordController.clear();
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> login(BuildContext context, WidgetRef ref) async {
    if (isLoading) return false;
    
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      final l10n = AppLocalizations.of(context);
      _showSnackBar(
        context,
        l10n?.fillAllFields ?? "Preencha todos os campos!",
        isError: true,
      );
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final authService = ref.read(authServiceProvider);
      final deviceIdManager = ref.read(deviceIdManagerProvider);
      final deviceId = await deviceIdManager.getDeviceId();

      final fcmToken = FCMService().token;
      final systemLocale = ui.PlatformDispatcher.instance.locale.languageCode;
      
      log('Device language detected: $systemLocale', name: 'LoginController');

      final loginRequester = LoginRequestDTO(
        identifier: emailController.text.trim(),
        password: passwordController.text.trim(),
        deviceFcmToken: fcmToken,
        deviceLanguage: systemLocale,
      );

      await authService.login(user: loginRequester, deviceId: deviceId);

      if (!context.mounted) {
        log("Context not mounted after login", name: "LoginController");
        return false;
      }

      log("✅ [Login] Authentication successful", name: "LoginController");

      ref.read(authControllerProvider).updateUser();
      final _ = ref.refresh(currentUserProvider.future);

      if (!context.mounted) return false;

      log("✅ [Login] Auth state updated, navigating to home", name: "LoginController");
      
      final l10n = AppLocalizations.of(context);
      _showSnackBar(
        context,
        l10n?.welcomeBack ?? 'Welcome back!',
        isError: false,
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      
      return true;
    } on ForbiddenException catch (e) {
      log("Account verification required", name: "LoginController");
      
      if (!context.mounted) return false;
      
      final message = e.message.toLowerCase();
      if (message.contains('not verified') || message.contains('verify')) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerificationCodePage(
              identifier: emailController.text.trim(),
            ),
          ),
        );
      } else {
        ErrorHandler.showErrorSnackBar(context, e);
      }
      return false;
    } on AccountNotVerifiedException catch (e) {
      log("Account not verified, redirecting to verification", name: "LoginController");
      
      if (!context.mounted) return false;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerificationCodePage(identifier: e.email),
        ),
      );
      return false;
    } catch (e) {
      log("Login error: $e", name: "LoginController");
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

final loginControllerProvider = ChangeNotifierProvider((ref) {
  return LoginController();
});
