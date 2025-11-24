import 'package:flutter/material.dart';
import 'package:rpa/l10n/app_localizations.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';

class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (error is ValidationException) {
      return _handleValidationError(error, l10n);
    } else if (error is UnauthorizedException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid credentials') ||
          message.contains('invalid email') ||
          message.contains('invalid password') ||
          message.contains('wrong password') ||
          message.contains('wrong email')) {
        return l10n.errorInvalidCredentials;
      }
      return l10n.errorSessionExpired;
    } else if (error is ForbiddenException) {
      final message = error.message.toLowerCase();
      if (message.contains('not verified') ||
          message.contains('verify') ||
          message.contains('verification')) {
        return l10n.errorAccountNotVerified;
      }
      return l10n.errorNoPermission;
    } else if (error is NotFoundException) {
      return l10n.errorNotFound;
    } else if (error is NetworkException) {
      return l10n.errorNoInternet;
    } else if (error is TimeoutException) {
      return l10n.errorTimeout;
    } else if (error is ServerException) {
      return l10n.errorServerUnavailable;
    } else if (error is BadRequestException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid credentials') ||
          message.contains('invalid email') ||
          message.contains('invalid password') ||
          message.contains('wrong password') ||
          message.contains('wrong email')) {
        return l10n.errorInvalidCredentials;
      }
      return error.message.isNotEmpty
          ? _sanitizeBackendMessage(error.message, l10n)
          : l10n.errorInvalidData;
    } else if (error is HttpException) {
      return _sanitizeBackendMessage(error.message, l10n);
    } else if (error is Exception) {
      return l10n.errorUnexpected;
    } else {
      return l10n.errorGeneric;
    }
  }

  static String _handleValidationError(ValidationException error, AppLocalizations l10n) {
    if (error.errors != null && error.errors!.isNotEmpty) {
      final firstError = error.errors!.values.first.first;
      return _sanitizeBackendMessage(firstError, l10n);
    }
    return error.message.isNotEmpty
        ? _sanitizeBackendMessage(error.message, l10n)
        : l10n.errorInvalidData;
  }

  static String _sanitizeBackendMessage(String message, AppLocalizations l10n) {
    final cleanMessage = message.toLowerCase();

    if (cleanMessage.contains('invalid credentials') ||
        cleanMessage.contains('invalid email') ||
        cleanMessage.contains('invalid password') ||
        cleanMessage.contains('wrong password') ||
        cleanMessage.contains('wrong email')) {
      return l10n.errorInvalidCredentials;
    }

    if (cleanMessage.contains('page not found') ||
        cleanMessage.contains('endpoint not found') ||
        cleanMessage.contains('route not found')) {
      return l10n.errorNotFound;
    }

    if (cleanMessage.contains('internal server error') ||
        cleanMessage.contains('500') ||
        cleanMessage.contains('database') ||
        cleanMessage.contains('sql') ||
        cleanMessage.contains('exception') ||
        cleanMessage.contains('error:') ||
        cleanMessage.contains('stack trace')) {
      return l10n.errorServerUnavailable;
    }

    if (cleanMessage.contains('unauthorized') ||
        cleanMessage.contains('token')) {
      return l10n.errorSessionExpired;
    }

    if (cleanMessage.contains('not verified') ||
        cleanMessage.contains('verification required')) {
      return l10n.errorAccountNotVerified;
    }

    if (cleanMessage.contains('forbidden') ||
        cleanMessage.contains('permission')) {
      return l10n.errorNoPermission;
    }

    if (cleanMessage.contains('not found') || cleanMessage.contains('404')) {
      return l10n.errorNotFound;
    }

    if (cleanMessage.contains('network') ||
        cleanMessage.contains('connection')) {
      return l10n.errorNoInternet;
    }

    if (cleanMessage.contains('timeout')) {
      return l10n.errorTimeout;
    }

    if (cleanMessage.startsWith('http') ||
        cleanMessage.contains('://') ||
        message.length > 100) {
      return l10n.errorUnexpected;
    }

    return message;
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    if (!context.mounted) return;

    final message = getUserFriendlyMessage(error, context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    final message = getUserFriendlyMessage(error, context);
    final isNetworkError =
        error is NetworkException || error is TimeoutException;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? (isNetworkError ? 'Erro de Conexão' : 'Ops!')),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Tentar Novamente'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(onRetry != null ? 'Cancelar' : 'OK'),
          ),
        ],
      ),
    );
  }

  static IconData getErrorIcon(dynamic error) {
    if (error is NetworkException || error is TimeoutException) {
      return Icons.wifi_off;
    } else if (error is UnauthorizedException) {
      return Icons.lock_outline;
    } else if (error is ForbiddenException) {
      return Icons.block;
    } else if (error is NotFoundException) {
      return Icons.search_off;
    } else if (error is ValidationException) {
      return Icons.error_outline;
    } else if (error is ServerException) {
      return Icons.cloud_off;
    } else {
      return Icons.warning_amber;
    }
  }

  static Color getErrorColor(dynamic error) {
    if (error is NetworkException || error is TimeoutException) {
      return Colors.orange;
    } else if (error is UnauthorizedException || error is ForbiddenException) {
      return Colors.red.shade700;
    } else if (error is ValidationException) {
      return Colors.amber.shade700;
    } else {
      return Colors.red;
    }
  }
}
