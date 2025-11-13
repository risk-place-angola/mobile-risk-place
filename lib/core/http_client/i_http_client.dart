import 'package:dio/dio.dart';

abstract class IHttpClient {
  Future<Response> get(String route, {Map<String, dynamic>? body});
  Future<Response> post(String route, {Map<String, dynamic>? body});
  Future<Response> patch(String route, {required Map<String, dynamic> body});
  Future<Response> put(String route, {Map<String, dynamic>? body});
  Future<void> delete(String route);
}
