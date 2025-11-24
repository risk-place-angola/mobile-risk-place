import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/presenter/pages/auth/reset_password_page.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _identifierController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  bool _isEmail(String value) => value.contains('@');
  
  bool _isPhone(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');
    return RegExp(r'^\+?\d{10,15}$').hasMatch(cleaned);
  }

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final identifier = _identifierController.text.trim();
      
      final fallbackResponse = await authService.forgotPassword(identifier: identifier);

      if (!mounted) return;

      final l10n = AppLocalizations.of(context);
      String? fallbackEmail;
      
      if (fallbackResponse?.isSentViaEmail == true) {
        fallbackEmail = fallbackResponse!.email ?? identifier;
        _showSnackBar(l10n?.codeSentTo(fallbackEmail) ?? 'Code sent to $fallbackEmail', icon: Icons.info_outline);
      } else {
        _showSnackBar(l10n?.codeSentSuccess ?? 'Code sent successfully!');
      }
      
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(
            identifier: identifier,
            fallbackEmail: fallbackEmail,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        _showSnackBar(l10n?.errorSendingCode ?? 'Error sending code', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: icon != null
            ? Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message)),
                ],
              )
            : Text(message),
        backgroundColor: isError 
            ? Colors.red 
            : (icon != null ? const Color(0xFFF39C12) : Colors.green),
        duration: Duration(seconds: icon != null ? 5 : 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_reset,
                  color: Color(0xFFF39C12),
                  size: 80,
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)?.forgotPasswordTitle ?? 'Forgot your password?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.forgotPasswordSubtitle ?? 'Enter your email or phone to receive\nthe recovery code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    final l10n = AppLocalizations.of(context);
                    if (value == null || value.isEmpty) {
                      return l10n?.identifierRequired ?? 'Email or phone is required';
                    }
                    if (!_isEmail(value) && !_isPhone(value)) {
                      return l10n?.invalidIdentifier ?? 'Enter a valid email or phone number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)?.emailOrPhone ?? 'Email or Phone',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFFF39C12)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF39C12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleSendCode,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)?.sendCode ?? 'Send code',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
