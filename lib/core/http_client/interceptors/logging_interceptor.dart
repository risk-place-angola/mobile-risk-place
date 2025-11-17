import 'dart:developer' as dev;
import 'package:dio/dio.dart';

/// Custom interceptor for logging HTTP requests and responses
class LoggingInterceptor extends Interceptor {
  final bool logRequest;
  final bool logResponse;
  final bool logError;

  LoggingInterceptor({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequest) {
      dev.log(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        name: 'HTTP REQUEST',
      );
      dev.log('METHOD: ${options.method}', name: 'HTTP REQUEST');
      dev.log('URL: ${options.uri}', name: 'HTTP REQUEST');
      if (options.headers.isNotEmpty) {
        dev.log('HEADERS: ${options.headers}', name: 'HTTP REQUEST');
      }
      if (options.data != null) {
        dev.log('BODY: ${options.data}', name: 'HTTP REQUEST');
      }
      if (options.queryParameters.isNotEmpty) {
        dev.log('QUERY: ${options.queryParameters}', name: 'HTTP REQUEST');
      }
      dev.log(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        name: 'HTTP REQUEST',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logResponse) {
      dev.log(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        name: 'HTTP RESPONSE',
      );
      dev.log('STATUS CODE: ${response.statusCode}', name: 'HTTP RESPONSE');
      dev.log('URL: ${response.requestOptions.uri}', name: 'HTTP RESPONSE');
      dev.log('DATA: ${response.data}', name: 'HTTP RESPONSE');
      dev.log(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        name: 'HTTP RESPONSE',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logError) {
      dev.log(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        name: 'HTTP ERROR',
      );
      dev.log('ERROR TYPE: ${err.type}', name: 'HTTP ERROR');
      dev.log('URL: ${err.requestOptions.uri}', name: 'HTTP ERROR');
      dev.log('MESSAGE: ${err.message}', name: 'HTTP ERROR');
      if (err.response != null) {
        dev.log('STATUS CODE: ${err.response?.statusCode}', name: 'HTTP ERROR');
        dev.log('RESPONSE DATA: ${err.response?.data}', name: 'HTTP ERROR');
      }
      dev.log(
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        name: 'HTTP ERROR',
      );
    }
    handler.next(err);
  }
}
