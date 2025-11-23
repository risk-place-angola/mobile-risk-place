import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/core/error/error_handler.dart';
import 'package:rpa/core/device/device_id_manager.dart';
import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/data/providers/user_provider.dart';
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/data/services/alert_websocket_service.dart';
import 'package:rpa/presenter/controllers/auth.controller.dart';
import 'package:rpa/presenter/controllers/location.controller.dart';
import 'package:rpa/presenter/pages/home_page/home.page.dart';

class LoginController extends ChangeNotifier {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login(BuildContext context, WidgetRef ref) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      final l10n = AppLocalizations.of(context);
      _showSnackBar(
        context,
        l10n?.fillAllFields ?? "Preencha todos os campos!",
        isError: true,
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final authService = ref.read(authServiceProvider);
      final deviceIdManager = ref.read(deviceIdManagerProvider);
      final deviceId = await deviceIdManager.getDeviceId();

      final loginRequester = LoginRequestDTO(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await authService.login(user: loginRequester, deviceId: deviceId);

      if (!context.mounted) {
        log("Context not mounted", name: "LoginController");
        return;
      }

      // Update auth state
      ref.read(authControllerProvider).updateUser();

      // Refresh user provider to load new user data
      final _ = ref.refresh(currentUserProvider.future);

      log("🔐 [Login] Upgrading to authenticated WebSocket connection...",
          name: "LoginController");

      final wsService = ref.read(alertWebSocketProvider);
      wsService.disconnect();

      wsService.connect(
        token: '',
        onAlert: (alertData) {
          log("🚨 [Login] Alert: ${alertData['message']}",
              name: "LoginController");
        },
        onError: (error) {
          log("❌ [Login] WebSocket error: $error", name: "LoginController");
        },
        onConnected: () {
          log("✅ [Login] Authenticated WebSocket connected!",
              name: "LoginController");
        },
        onDisconnected: () {
          log("🔌 [Login] WebSocket disconnected", name: "LoginController");
        },
      );

      // ========================================================================
      // 📍 REQUEST LOCATION PERMISSION
      // ========================================================================
      // Request location permission after successful login
      final locationController = ref.read(locationControllerProvider);
      final locationPermissionGranted =
          await locationController.requestLocationPermission();

      if (!locationPermissionGranted) {
        log("⚠️ [Login] Location permission denied", name: "LoginController");
      } else {
        log("✅ [Login] Location permission granted", name: "LoginController");
      }

      if (!context.mounted) return;

      _showSuccessDialog(context);

      await Future.delayed(const Duration(milliseconds: 1500));

      if (!context.mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      log("❌ Login error: $e", name: "LoginController");
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
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
                  AppLocalizations.of(context)?.loginSuccessful ?? 'Login Realizado!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.welcomeBack ?? 'Bem-vindo de volta',
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

final loginControllerProvider = ChangeNotifierProvider((ref) {
  return LoginController();
});
