import 'package:flutter/material.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';

class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is ValidationException) {
      return _handleValidationError(error);
    } else if (error is UnauthorizedException) {
      return 'Sua sessão expirou. Por favor, faça login novamente.';
    } else if (error is ForbiddenException) {
      return 'Você não tem permissão para realizar esta ação.';
    } else if (error is NotFoundException) {
      return 'As informações solicitadas não foram encontradas.';
    } else if (error is NetworkException) {
      return 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
    } else if (error is TimeoutException) {
      return 'A operação está demorando muito. Verifique sua conexão e tente novamente.';
    } else if (error is ServerException) {
      return 'Nossos servidores estão temporariamente indisponíveis. Tente novamente em alguns instantes.';
    } else if (error is BadRequestException) {
      return error.message.isNotEmpty
          ? error.message
          : 'Os dados enviados são inválidos. Verifique e tente novamente.';
    } else if (error is HttpException) {
      return _sanitizeBackendMessage(error.message);
    } else if (error is Exception) {
      return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
    } else {
      return 'Algo deu errado. Por favor, tente novamente mais tarde.';
    }
  }

  static String _handleValidationError(ValidationException error) {
    if (error.errors != null && error.errors!.isNotEmpty) {
      final firstError = error.errors!.values.first.first;
      return _sanitizeBackendMessage(firstError);
    }
    return error.message.isNotEmpty
        ? _sanitizeBackendMessage(error.message)
        : 'Por favor, verifique os dados informados e tente novamente.';
  }

  static String _sanitizeBackendMessage(String message) {
    final cleanMessage = message.toLowerCase();

    if (cleanMessage.contains('page not found') ||
        cleanMessage.contains('endpoint not found') ||
        cleanMessage.contains('route not found')) {
      return 'Esta funcionalidade ainda não está disponível. Estamos trabalhando nisso.';
    }

    if (cleanMessage.contains('internal server error') ||
        cleanMessage.contains('500') ||
        cleanMessage.contains('database') ||
        cleanMessage.contains('sql') ||
        cleanMessage.contains('exception') ||
        cleanMessage.contains('error:') ||
        cleanMessage.contains('stack trace')) {
      return 'Nossos servidores estão temporariamente indisponíveis. Tente novamente em alguns instantes.';
    }

    if (cleanMessage.contains('unauthorized') ||
        cleanMessage.contains('token')) {
      return 'Sua sessão expirou. Por favor, faça login novamente.';
    }

    if (cleanMessage.contains('forbidden') ||
        cleanMessage.contains('permission')) {
      return 'Você não tem permissão para realizar esta ação.';
    }

    if (cleanMessage.contains('not found') || cleanMessage.contains('404')) {
      return 'As informações solicitadas não foram encontradas.';
    }

    if (cleanMessage.contains('network') ||
        cleanMessage.contains('connection')) {
      return 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
    }

    if (cleanMessage.contains('timeout')) {
      return 'A operação está demorando muito. Tente novamente.';
    }

    if (cleanMessage.startsWith('http') ||
        cleanMessage.contains('://') ||
        message.length > 100) {
      return 'Ocorreu um erro ao processar sua solicitação. Tente novamente.';
    }

    return message;
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    if (!context.mounted) return;

    final message = getUserFriendlyMessage(error);

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

    final message = getUserFriendlyMessage(error);
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
