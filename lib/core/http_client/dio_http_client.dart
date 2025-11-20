import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/constants.dart';
import 'package:rpa/core/database_helper/database_helper.dart';

import 'i_http_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'exceptions/http_exceptions.dart';

/// Provider for HTTP client instance
final httpClientProvider = Provider<IHttpClient>((ref) {
  final dbHelper = ref.read(dbHelperProvider);
  return HttpClient(dbHelper);
});

/// HTTP client implementation using Dio
class HttpClient implements IHttpClient {
  late final Dio _dio;
  final IDBHelper _dbHelper;

  HttpClient(this._dbHelper) {
    _dio = Dio(_createBaseOptions());
    _setupInterceptors();
  }

  /// Create base Dio options
  BaseOptions _createBaseOptions() {
    return BaseOptions(
      baseUrl: BASE_URL,
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) =>
          status != null &&
          status < 600, // Accept all status codes to handle them properly
    );
  }

  /// Setup interceptors for logging and error handling
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      AuthInterceptor(_dbHelper, _dio),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  @override
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  @override
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  @override
  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  @override
  Future<Response> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  @override
  Future<Response> delete(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw _extractException(e);
    }
  }

  /// Extract custom exception from DioException
  HttpException _extractException(DioException error) {
    if (error.error is HttpException) {
      return error.error as HttpException;
    }
    return HttpException(
      message: error.message ?? 'Erro desconhecido',
      statusCode: error.response?.statusCode,
    );
  }
}
