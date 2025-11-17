import 'package:dio/dio.dart';

/// Abstract interface for HTTP client operations
abstract class IHttpClient {
  /// GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters});
  
  /// POST request
  Future<Response> post(String path, {Map<String, dynamic>? data});
  
  /// PUT request
  Future<Response> put(String path, {Map<String, dynamic>? data});
  
  /// PATCH request
  Future<Response> patch(String path, {Map<String, dynamic>? data});
  
  /// DELETE request
  Future<Response> delete(String path, {Map<String, dynamic>? data});
}
