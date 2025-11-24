import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/data/services/auth.service.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';
import 'package:rpa/presenter/pages/auth/reset_password_page.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
enum VerificationFlow { registration, passwordReset }

class VerificationCodePage extends ConsumerStatefulWidget {
  final String identifier;
  final VerificationFlow flow;

  const VerificationCodePage({
    super.key,
    required this.identifier,
    this.flow = VerificationFlow.registration,
  });

  @override
  ConsumerState<VerificationCodePage> createState() =>
      _VerificationCodePageState();
}

class _VerificationCodePageState extends ConsumerState<VerificationCodePage> {
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isConfirming = false;
  bool _hasNavigated = false;
  int _resendCooldown = 60;
  int _expirationTime = 600;
  int _lockoutTime = 0;
  int _attemptCount = 0;
  bool _canResend = false;
  bool _isLocked = false;

  Timer? _resendTimer;
  Timer? _expirationTimer;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
    _startResendCooldown();
    _startExpirationTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _expirationTimer?.cancel();
    _lockoutTimer?.cancel();
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    if (!mounted) return;
    final code = _codeController.text.trim();
    if (code.length == 6 && !_isLoading && !_isLocked && !_isConfirming) {
      log('Code filled: ${code.length} digits', name: 'VerificationCodePage');
      Future.microtask(() => _handleConfirm());
    }
  }

  void _startResendCooldown() {
    if (!mounted) return;
    setState(() {
      _resendCooldown = 60;
      _canResend = false;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _startExpirationTimer() {
    if (!mounted) return;
    setState(() => _expirationTime = 600);

    _expirationTimer?.cancel();
    _expirationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_expirationTime > 0) {
        setState(() => _expirationTime--);
      } else {
        timer.cancel();
      }
    });
  }

  void _startLockoutTimer() {
    if (!mounted) return;
    setState(() {
      _lockoutTime = 900;
      _isLocked = true;
    });

    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lockoutTime > 0) {
        setState(() => _lockoutTime--);
      } else {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          _isLocked = false;
          _attemptCount = 0;
        });
      }
    });
  }

  void _clearCode() {
    _codeController.clear();
    _codeFocusNode.requestFocus();
  }

  Future<void> _handleConfirm() async {
    if (_isLocked || !mounted || _hasNavigated) return;
    if (_isConfirming) return;
    _isConfirming = true;

    final l10n = AppLocalizations.of(context);
    final code = _codeController.text.trim();

    if (code.length != 6) {
      _isConfirming = false;
      _showSnackBar(l10n?.fieldRequired ?? 'Enter verification code', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      final success = await authService.verifyCode(
        identifier: widget.identifier,
        code: code,
      );

      if (!mounted) return;

      if (success) {
        log('Verification successful', name: 'VerificationCodePage');
        
        _hasNavigated = true;
        _resendTimer?.cancel();
        _expirationTimer?.cancel();
        _lockoutTimer?.cancel();
        
        if (widget.flow == VerificationFlow.passwordReset) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ResetPasswordPage(identifier: widget.identifier),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } on BadRequestException catch (e) {
      if (!mounted) return;

      final message = e.message.toLowerCase();
      final l10n = AppLocalizations.of(context);

      if (message.contains('too many') || message.contains('wait')) {
        log('Account locked due to too many attempts', name: 'VerificationCodePage');
        _startLockoutTimer();
        _showSnackBar(l10n?.verificationTooManyAttempts ?? 'Too many incorrect attempts. Wait 15 minutes', isError: true);
      } else if (message.contains('expired')) {
        log('Verification code expired', name: 'VerificationCodePage');
        _showSnackBar(l10n?.verificationCodeExpired ?? 'Code expired. Request a new one.', isError: true);
        if (mounted) setState(() {
          _canResend = true;
          _resendCooldown = 0;
        });
      } else if (message.contains('invalid') || message.contains('incorrect')) {
        if (!mounted) return;
        setState(() {
          _attemptCount++;
        });
        _clearCode();

        final attemptsLeft = 5 - _attemptCount;
        log('Invalid code attempt: $_attemptCount/5', name: 'VerificationCodePage');

        if (_attemptCount >= 5) {
          _startLockoutTimer();
          _showSnackBar(l10n?.verificationTooManyAttempts ?? 'Too many incorrect attempts. Wait 15 minutes', isError: true);
        } else {
          _showSnackBar(l10n?.verificationAttemptsLeft(attemptsLeft) ?? '$attemptsLeft attempts left', isError: true);
        }
      } else {
        _showSnackBar(e.message, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      log('Verification error: $e', name: 'VerificationCodePage');

      final l10n = AppLocalizations.of(context);
      _showSnackBar('${l10n?.errorConfirmingCode ?? "Error confirming code"}: $e', isError: true);
    } finally {
      _isConfirming = false;
      if (mounted && !_hasNavigated) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendCode() async {
    if (!_canResend || _isLoading || _isLocked || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      final fallbackResponse = await authService.resendVerificationCode(identifier: widget.identifier);

      if (!mounted) return;

      log('Verification code resent', name: 'VerificationCodePage');

      final l10n = AppLocalizations.of(context);
      
      if (fallbackResponse?.isSentViaEmail == true) {
        final email = fallbackResponse!.email ?? widget.identifier;
        _showSnackBar(
          l10n?.codeSentTo(email) ?? 'Code sent to $email',
          icon: Icons.info_outline,
          color: const Color(0xFFF39C12),
        );
      } else {
        _showSnackBar(l10n?.codeResentSuccess ?? 'Code resent successfully!');
      }
      
      _clearCode();
      _startResendCooldown();
      _startExpirationTimer();
      setState(() => _attemptCount = 0);
    } on BadRequestException catch (e) {
      if (!mounted) return;

      final message = e.message.toLowerCase();
      final l10n = AppLocalizations.of(context);

      if (message.contains('wait')) {
        final seconds = _extractSecondsFromMessage(message);
        _showSnackBar(l10n?.verificationWaitBeforeResend(seconds) ?? 'Wait $seconds seconds before resending', isError: true);
      } else if (message.contains('too many') || message.contains('locked')) {
        _startLockoutTimer();
        _showSnackBar(l10n?.verificationTooManyAttempts ?? 'Too many attempts. Wait 15 minutes', isError: true);
      } else {
        _showSnackBar(e.message, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      log('Resend code error: $e', name: 'VerificationCodePage');

      final l10n = AppLocalizations.of(context);
      _showSnackBar('${l10n?.errorResendingCode ?? "Error resending code"}: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _extractSecondsFromMessage(String message) {
    final match = RegExp(r'(\d+)').firstMatch(message);
    return match != null ? int.tryParse(match.group(1)!) ?? 60 : 60;
  }

  void _showSnackBar(String message, {bool isError = false, IconData? icon, Color? color}) {
    if (!mounted) return;
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
        backgroundColor: color ?? (isError ? Colors.red : Colors.green),
        duration: Duration(seconds: icon != null ? 5 : 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _maskContact(String contact) {
    if (contact.contains('@')) {
      final parts = contact.split('@');
      final username = parts[0];
      if (username.length > 2) {
        return '${username.substring(0, 2)}***@${parts[1]}';
      }
      return '***@${parts[1]}';
    } else {
      if (contact.length > 4) {
        return '***${contact.substring(contact.length - 4)}';
      }
      return contact;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.mail_outline,
                color: Color(0xFFF39C12),
                size: 70,
              ),
              const SizedBox(height: 24),
              Text(
                l10n?.verificationCodeTitle ?? 'Verification Code',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.verificationCodeSentTo(_maskContact(widget.identifier)) ??
                    'Code sent to ${_maskContact(widget.identifier)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 40),

              GestureDetector(
                onTap: () {
                  if (!_isLoading && !_isLocked) _codeFocusNode.requestFocus();
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final spacing = 12.0;
                    final totalSpacing = spacing * 5;
                    final boxSize = ((maxWidth - totalSpacing) / 6).clamp(45.0, 56.0);
                    final fontSize = (boxSize * 0.43).clamp(18.0, 24.0);

                    return Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            final hasDigit = _codeController.text.length > index;
                            final isCurrent = _codeController.text.length == index;
                            
                            return Container(
                              width: boxSize,
                              height: boxSize,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrent && _codeFocusNode.hasFocus
                                      ? const Color(0xFFF39C12)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                hasDigit ? _codeController.text[index] : '',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ),
                        Opacity(
                          opacity: 0.01,
                          child: TextField(
                            controller: _codeController,
                            focusNode: _codeFocusNode,
                            keyboardType: TextInputType.number,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            textInputAction: TextInputAction.done,
                            maxLength: 6,
                            enabled: !_isLoading && !_isLocked && !_hasNavigated,
                            enableInteractiveSelection: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              TextButton.icon(
                onPressed: (_isLoading || _isLocked || _hasNavigated) ? null : _clearCode,
                icon: const Icon(Icons.clear, size: 16),
                label: Text(l10n?.clear ?? 'Clear'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              // Status messages
              if (_isLocked)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n?.verificationAccountLocked(_lockoutTime ~/ 60) ??
                              'Account locked. Wait ${_lockoutTime ~/ 60} minutes',
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_attemptCount > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_outlined,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.verificationAttemptsLeft(5 - _attemptCount) ??
                            '${5 - _attemptCount} attempts left',
                        style:
                            const TextStyle(color: Colors.orange, fontSize: 14),
                      ),
                    ],
                  ),
                ),

              if (_expirationTime > 0 && !_isLocked)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    l10n?.verificationCodeExpiresIn(
                          _expirationTime ~/ 60,
                          (_expirationTime % 60)
                              .toString()
                              .padLeft(2, '0'),
                        ) ??
                        'Code expires in ${_formatTime(_expirationTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _expirationTime < 120
                          ? Colors.red
                          : Colors.white.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 28),

              // Confirm button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF39C12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                    onPressed: (_isLoading || _isLocked || _hasNavigated) ? null : _handleConfirm,
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
                          l10n?.confirm ?? 'Confirm',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Resend button
              TextButton(
                onPressed: (_isLoading || !_canResend || _isLocked || _hasNavigated)
                    ? null
                    : _handleResendCode,
                child: Text(
                  _canResend
                      ? (l10n?.resendCode ?? 'Resend code')
                      : l10n?.verificationResendIn(_resendCooldown) ??
                          'Resend in ${_resendCooldown}s',
                  style: TextStyle(
                    color: _canResend
                        ? const Color(0xFFF39C12)
                        : Colors.white.withOpacity(0.4),
                    fontSize: 16,
                    fontWeight: _canResend ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
