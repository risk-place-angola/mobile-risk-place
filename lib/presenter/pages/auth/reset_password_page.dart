import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';
import 'package:rpa/presenter/pages/auth/forgot_password_page.dart';
import 'package:rpa/presenter/controllers/login.controller.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String identifier;
  final String? fallbackEmail;

  const ResetPasswordPage({
    super.key,
    required this.identifier,
    this.fallbackEmail,
  });

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isConfirming = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasNavigated = false;
  int _attemptCount = 0;
  int _resendCooldown = 60;
  int _expirationTime = 600;
  bool _canResend = false;
  
  Timer? _resendTimer;
  Timer? _expirationTimer;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
    _startTimers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _codeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeFocusNode.dispose();
    _resendTimer?.cancel();
    _expirationTimer?.cancel();
    super.dispose();
  }

  void _onCodeChanged() {
    final code = _codeController.text.trim();
    if (code.length == 6 && mounted && !_isConfirming && !_hasNavigated) {
      _codeFocusNode.unfocus();
      Future.microtask(() {
        if (mounted && !_isConfirming && !_hasNavigated) {
          if (_formKey.currentState?.validate() ?? false) {
            _handleResetPassword();
          }
        }
      });
    }
  }

  void _startTimers() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });

    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_expirationTime > 0) {
          _expirationTime--; 
        } else {
          timer.cancel();
          _showExpiredDialog();
        }
      });
    });
  }

  void _showExpiredDialog() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Code Expired'),
        content: const Text('The verification code has expired. Please request a new one.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
              );
            },
            child: Text(l10n?.resendCode ?? 'Request New Code'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResend() async {
    if (!_canResend || _isLoading || _isConfirming || _hasNavigated || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.forgotPassword(identifier: widget.identifier);

      if (!mounted) return;

      final l10n = AppLocalizations.of(context);
      _showSnackBar(l10n?.codeSentSuccess ?? 'Code sent successfully!');
      
      setState(() {
        _resendCooldown = 60;
        _expirationTime = 600;
        _canResend = false;
        _attemptCount = 0;
      });
      
      _resendTimer?.cancel();
      _expirationTimer?.cancel();
      _startTimers();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        _showSnackBar(l10n?.errorSendingCode ?? 'Error sending code', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    if (_hasNavigated || !mounted || _isConfirming) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showSnackBar('Please enter the 6-digit code', isError: true);
      return;
    }

    _isConfirming = true;
    if (mounted) setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.resetPassword(
        identifier: widget.identifier,
        code: code,
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        log('Password reset successful', name: 'ResetPasswordPage');
        
        _hasNavigated = true;
        
        _resendTimer?.cancel();
        _expirationTimer?.cancel();
        
        _codeController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        
        try {
          ref.read(loginControllerProvider).reset();
        } catch (e) {
          log('Failed to reset login controller: $e', name: 'ResetPasswordPage');
        }
        
        _showSnackBar('Password reset successfully!');
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } on BadRequestException catch (e) {
      if (!mounted || _hasNavigated) return;

      final message = e.message.toLowerCase();
      final errorData = e.data;
      String? errorCode;
      
      if (errorData is Map && errorData.containsKey('error')) {
        final error = errorData['error'];
        if (error != null && error is Map<String, dynamic> && error.containsKey('error_code')) {
          errorCode = error['error_code'] as String?;
        }
      }

      log('Reset password error: code=$errorCode, message=$message', name: 'ResetPasswordPage');

      if (errorCode == 'CODE_EXPIRED_RESET' || message.contains('expired')) {
        _showExpiredDialog();
      } else if (errorCode == 'INVALID_CODE_RESET' || message.contains('invalid')) {
        if (mounted) setState(() => _attemptCount++);
        final attemptsLeft = 5 - _attemptCount;
        final l10n = AppLocalizations.of(context);
        
        if (_attemptCount >= 5) {
          _showSnackBar(
            l10n?.verificationTooManyAttempts ?? 'Too many attempts. Wait 15 minutes',
            isError: true,
          );
          if (mounted && !_hasNavigated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
            );
          }
        } else {
          _showSnackBar(
            l10n?.verificationAttemptsLeft(attemptsLeft) ?? '$attemptsLeft attempts left',
            isError: true,
          );
        }
      } else {
        _showSnackBar('Error resetting password', isError: true);
      }
    } catch (e) {
      if (mounted && !_hasNavigated) {
        log('Reset password exception: $e', name: 'ResetPasswordPage');
        _showSnackBar('Error resetting password', isError: true);
      }
    } finally {
      _isConfirming = false;
      if (mounted && !_hasNavigated) {
        setState(() => _isLoading = false);
      }
    }
  }



  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (!_hasNavigated) Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 48 : 24,
                vertical: isSmallScreen ? 16 : 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.vpn_key,
                      color: const Color(0xFFF39C12),
                      size: isSmallScreen ? 60 : 80,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Text(
                      l10n?.newPassword ?? 'New Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    if (widget.fallbackEmail != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Code sent to\n${widget.fallbackEmail}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFF39C12),
                          ),
                        ),
                      ),
                    Text(
                      'Enter the 6-digit code and your new password',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16213E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _expirationTime < 60
                              ? Colors.red.withOpacity(0.5)
                              : const Color(0xFFF39C12).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: _expirationTime < 60 ? Colors.red : const Color(0xFFF39C12),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Time remaining: ${_formatTime(_expirationTime)}',
                            style: TextStyle(
                              color: _expirationTime < 60 ? Colors.red : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 28),
                    Text(
                      l10n?.verificationCode ?? 'Verification Code',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF16213E),
                      ),
                      child: TextFormField(
                        controller: _codeController,
                        focusNode: _codeFocusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          hintText: '------',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            letterSpacing: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF16213E),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n?.enterVerificationCode ?? 'Enter verification code';
                          }
                          if (value.length != 6) {
                            return l10n?.codeMustBe6Digits ?? 'Code must be 6 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Text(
                      l10n?.newPassword ?? 'New Password',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF16213E),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: l10n?.enterNewPassword ?? 'Enter new password',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFF39C12)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF16213E),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 8) {
                            return l10n?.passwordTooShort ?? 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    Text(
                      'Confirm Password',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF16213E),
                      ),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: l10n?.confirmPassword ?? 'Confirm password',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFF39C12)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF16213E),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return l10n?.passwordsDontMatch ?? 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _isConfirming || _hasNavigated) ? null : _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF39C12),
                          disabledBackgroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                l10n?.resetPassword ?? 'Reset Password',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _canResend && !_isLoading ? _handleResend : null,
                      child: Text(
                        _canResend
                            ? l10n?.resendCode ?? 'Resend Code'
                            : 'Resend code in ${_resendCooldown}s',
                        style: TextStyle(
                          color: _canResend ? const Color(0xFFF39C12) : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
