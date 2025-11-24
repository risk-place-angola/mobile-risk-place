import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/core/error/error_handler.dart';
import 'package:rpa/core/services/fcm_service.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/core/managers/anonymous_user_manager.dart';
import 'package:rpa/presenter/pages/auth/verification_code_page.dart';

class RegisterController extends ChangeNotifier {
  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
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

      if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }

      final authService = ref.read(authServiceProvider);
      final anonymousManager = ref.read(anonymousUserManagerProvider);
      final deviceId = anonymousManager.deviceId;

      final fcmToken = FCMService().token;
      final systemLocale = ui.PlatformDispatcher.instance.locale.languageCode;
      
      log('Device language detected: $systemLocale', name: 'RegisterController');

      final registerDto = RegisterRequestDTO(
        name: name,
        email: email,
        password: password,
        phone: phone,
        deviceFcmToken: fcmToken,
        deviceLanguage: systemLocale,
      );

      final fallbackResponse = await authService.register(
        registerDto: registerDto,
        deviceId: deviceId,
      );

      if (!context.mounted) return;

      log('Registration successful', name: 'RegisterController');

      if (fallbackResponse?.isSentViaEmail == true) {
        final l10n = AppLocalizations.of(context);
        final email = fallbackResponse!.email ?? registerDto.email;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n?.codeSentTo(email) ?? 'Code sent to $email'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFF39C12),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationCodePage(identifier: email),
        ),
      );
    } catch (e) {
      log('Registration error: $e', name: 'RegisterController');
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    } finally {
      setLoading(false);
    }
  }




}

final registerControllerProvider = ChangeNotifierProvider.autoDispose<RegisterController>((ref) {
  return RegisterController();
});
