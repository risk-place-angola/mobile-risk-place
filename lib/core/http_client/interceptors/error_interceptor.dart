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
            message: 'Request timeout',
          );

        case DioExceptionType.connectionError:
          if (error.error is SocketException) {
            final socketError = error.error as SocketException;
            if (socketError.osError?.errorCode == 7 ||
                socketError.osError?.errorCode == 61) {
              return NetworkException(
                message: 'Could not connect to server',
              );
            }
            return NetworkException(
              message: 'No internet connection',
            );
          }
          return NetworkException(
            message: 'Connection error',
          );

        case DioExceptionType.badResponse:
          return _handleStatusCodeError(error);

        case DioExceptionType.cancel:
          return HttpException(message: 'Request cancelled');

        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return NetworkException(
              message: 'No internet connection',
            );
          }
          if (error.error is FormatException) {
            return HttpException(
              message: 'Invalid server response',
            );
          }
          return HttpException(
            message: 'Unexpected error',
          );

        default:
          return HttpException(message: 'Unexpected error');
      }
    } catch (e) {
      return HttpException(
        message: 'Request processing error',
      );
    }
  }

  HttpException _handleStatusCodeError(DioException error) {
    try {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      String? message;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          final errorField = data['error'];
          if (errorField is Map<String, dynamic>) {
            message = errorField['message'] as String?;
          } else if (errorField is String) {
            message = errorField;
          }
        }
        message ??= data['message'] as String? ??
            data['msg'] as String? ??
            data['detail'] as String?;
      } else if (data is String) {
        message = data;
      }

      switch (statusCode) {
        case 400:
          return BadRequestException(
            message: message ?? 'Invalid request',
            data: data,
          );

        case 401:
          return UnauthorizedException(
            message: message ?? 'Unauthorized',
          );

        case 403:
          if (message != null && 
              (message.contains('not verified') ||
               message.contains('verification required') ||
               message.contains('verify'))) {
            return ForbiddenException(message: 'account not verified');
          }
          return ForbiddenException(
            message: message ?? 'Forbidden',
          );

        case 404:
          return NotFoundException(
            message: message ?? 'Not found',
          );

        case 409:
          return BadRequestException(
            message: message ?? 'Conflict',
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
            message: message ?? 'Validation error',
            errors: errors,
            data: data,
          );

        case 429:
          return HttpException(
            message: 'Too many requests',
            statusCode: statusCode,
            data: data,
          );

        case 500:
        case 502:
        case 503:
        case 504:
          return ServerException(
            message: 'Server error',
            statusCode: statusCode,
            data: data,
          );

        default:
          return HttpException(
            message: message ?? 'Request error',
            statusCode: statusCode,
            data: data,
          );
      }
    } catch (e) {
      return HttpException(
        message: 'Invalid server response',
        statusCode: error.response?.statusCode,
      );
    }
  }
}
