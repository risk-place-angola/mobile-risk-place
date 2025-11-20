import 'dart:io';
import 'package:dio/dio.dart';
import '../exceptions/http_exceptions.dart';

/// Interceptor for handling errors and converting them to custom exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _handleError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  HttpException _handleError(DioException error) {
    try {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException(
            message: 'A requisição demorou muito tempo. Tente novamente.',
          );

        case DioExceptionType.connectionError:
          if (error.error is SocketException) {
            final socketError = error.error as SocketException;
            if (socketError.osError?.errorCode == 7 ||
                socketError.osError?.errorCode == 61) {
              return NetworkException(
                message:
                    'Não foi possível conectar ao servidor. Verifique sua conexão.',
              );
            }
            return NetworkException(
              message: 'Sem conexão com a internet. Verifique sua conexão.',
            );
          }
          return NetworkException(
            message: 'Erro de conexão. Verifique sua internet.',
          );

        case DioExceptionType.badResponse:
          return _handleStatusCodeError(error);

        case DioExceptionType.cancel:
          return HttpException(message: 'Requisição cancelada');

        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return NetworkException(
              message: 'Sem conexão com a internet',
            );
          }
          if (error.error is FormatException) {
            return HttpException(
              message: 'Erro ao processar resposta do servidor',
            );
          }
          return HttpException(
            message: 'Ocorreu um erro inesperado',
          );

        default:
          return HttpException(message: 'Ocorreu um erro inesperado');
      }
    } catch (e) {
      return HttpException(
        message: 'Erro ao processar requisição',
      );
    }
  }

  HttpException _handleStatusCodeError(DioException error) {
    try {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      String? message;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ??
            data['error'] as String? ??
            data['msg'] as String? ??
            data['detail'] as String?;
      } else if (data is String) {
        message = data;
      }

      switch (statusCode) {
        case 400:
          return BadRequestException(
            message: message ?? 'Requisição inválida',
            data: data,
          );

        case 401:
          return UnauthorizedException(
            message: message ?? 'Credenciais inválidas ou sessão expirada',
          );

        case 403:
          return ForbiddenException(
            message:
                message ?? 'Você não tem permissão para acessar este recurso',
          );

        case 404:
          if (data is String && data.toLowerCase().contains('not found')) {
            return NotFoundException(
              message:
                  'Este recurso ainda não está disponível. Estamos trabalhando nisso.',
            );
          }
          return NotFoundException(
            message:
                message ?? 'As informações solicitadas não foram encontradas',
          );

        case 409:
          return BadRequestException(
            message:
                message ?? 'Conflito: esta operação não pode ser realizada',
            data: data,
          );

        case 422:
          Map<String, List<String>>? errors;
          if (data is Map<String, dynamic> && data.containsKey('errors')) {
            try {
              errors = (data['errors'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(
                  key,
                  value is List
                      ? value.map((e) => e.toString()).toList()
                      : [value.toString()],
                ),
              );
            } catch (_) {
              errors = null;
            }
          }
          return ValidationException(
            message: message ?? 'Erro de validação',
            errors: errors,
            data: data,
          );

        case 429:
          return HttpException(
            message:
                'Muitas requisições. Aguarde alguns instantes e tente novamente.',
            statusCode: statusCode,
            data: data,
          );

        case 500:
        case 502:
        case 503:
        case 504:
          return ServerException(
            message: 'Erro no servidor. Tente novamente mais tarde.',
            statusCode: statusCode,
            data: data,
          );

        default:
          return HttpException(
            message: message ?? 'Erro ao processar requisição',
            statusCode: statusCode,
            data: data,
          );
      }
    } catch (e) {
      return HttpException(
        message: 'Erro ao processar resposta do servidor',
        statusCode: error.response?.statusCode,
      );
    }
  }
}
