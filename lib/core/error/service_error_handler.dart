import 'dart:developer';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';

class ServiceErrorHandler {
  static Future<T> execute<T>({
    required Future<T> Function() operation,
    required String operationName,
    String? serviceName,
  }) async {
    try {
      return await operation();
    } on HttpException catch (e) {
      log(
        '❌ [$serviceName] $operationName failed: ${e.message}',
        name: serviceName ?? 'Service',
      );
      rethrow;
    } on FormatException catch (e) {
      log(
        '❌ [$serviceName] $operationName - Format error: ${e.message}',
        name: serviceName ?? 'Service',
      );
      throw HttpException(
        message: 'Erro ao processar dados do servidor',
      );
    } on TypeError catch (e) {
      log(
        '❌ [$serviceName] $operationName - Type error: $e',
        name: serviceName ?? 'Service',
      );
      throw HttpException(
        message: 'Erro ao processar resposta do servidor',
      );
    } catch (e, stackTrace) {
      log(
        '❌ [$serviceName] $operationName - Unexpected error: $e',
        name: serviceName ?? 'Service',
        error: e,
        stackTrace: stackTrace,
      );
      throw HttpException(
        message: 'Ocorreu um erro inesperado',
      );
    }
  }

  static T executeSync<T>({
    required T Function() operation,
    required String operationName,
    String? serviceName,
  }) {
    try {
      return operation();
    } on HttpException catch (e) {
      log(
        '❌ [$serviceName] $operationName failed: ${e.message}',
        name: serviceName ?? 'Service',
      );
      rethrow;
    } catch (e, stackTrace) {
      log(
        '❌ [$serviceName] $operationName - Unexpected error: $e',
        name: serviceName ?? 'Service',
        error: e,
        stackTrace: stackTrace,
      );
      throw HttpException(
        message: 'Ocorreu um erro inesperado',
      );
    }
  }
}
