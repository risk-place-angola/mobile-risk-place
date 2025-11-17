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
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'A requisição demorou muito tempo. Tente novamente.',
        );

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
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
        return HttpException(
          message: 'Erro desconhecido: ${error.message}',
        );

      default:
        return HttpException(message: 'Ocorreu um erro inesperado');
    }
  }

  HttpException _handleStatusCodeError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Try to extract message from response
    String? message;
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? 
                data['error'] as String? ?? 
                data['msg'] as String?;
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
          message: message ?? 'Você não tem permissão para acessar este recurso',
        );

      case 404:
        return NotFoundException(
          message: message ?? 'Recurso não encontrado',
        );

      case 422:
        Map<String, List<String>>? errors;
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          errors = (data['errors'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
              key,
              (value as List).map((e) => e.toString()).toList(),
            ),
          );
        }
        return ValidationException(
          message: message ?? 'Erro de validação',
          errors: errors,
          data: data,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: message ?? 'Erro no servidor. Tente novamente mais tarde.',
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
  }
}
