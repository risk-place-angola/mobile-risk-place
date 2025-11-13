import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/constants.dart';

import 'i_http_client.dart';

final httpClientProvider = Provider<IHttpClient>((ref) {
  final dio = Dio();
  return ClientHttpService(dio: dio);
});

class ClientHttpService implements IHttpClient {
  Dio dio;

  ClientHttpService({required this.dio}) {
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.sendTimeout = const Duration(seconds: 10);
    dio.options.responseType = ResponseType.json;
    dio.options.baseUrl = BASE_URL;
    dio.options.contentType = Headers.jsonContentType;

    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      requestBody: false,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));
  }

  @override
  Future<Response> get(String route, {Map<String, dynamic>? body}) async {
    try {
      final result = await dio.get(
        route,
        queryParameters: body,
      );
      return result;
    } on DioException catch (e) {
      log('GET request failed for route: $route, Error: $e',
          name: 'ClientHttpService');
      return Response(
        statusMessage:
            "{\"data\": null, \"message\": \"Ocorreu um erro interno\"}",
        statusCode: e.response?.statusCode ?? 500,
        requestOptions: RequestOptions(),
      );
    }
  }

  @override
  Future<Response> post(
    String route, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final data = await dio.post(route, data: body);
      log(data.data.toString(), name: "Response");
      return data;
    } on DioException catch (e) {
      log('POST request failed for route: $route, Error: $e',
          name: 'ClientHttpService');
      return Response(
        statusMessage:
            "{\"data\": null, \"message\": \"Ocorreu um erro interno\"}",
        statusCode: e.response?.statusCode ?? 500,
        requestOptions: RequestOptions(),
      );
    }
  }

  @override
  Future<Response> put(String route, {Map<String, dynamic>? body}) async {
    try {
      final data = await dio.put(
        route,
        data: body,
      );

      return data;
    } on DioException catch (e) {
      log('PUT request failed for route: $route, Error: $e',
          name: 'ClientHttpService');
      return Response(
        statusMessage:
            "{\"data\": null, \"message\": \"Ocorreu um erro interno\"}",
        statusCode: e.response?.statusCode ?? 500,
        requestOptions: RequestOptions(),
      );
    }
  }

  @override
  Future<void> delete(String route, {Map<String, dynamic>? body}) async {
    try {
      await dio.delete(
        route,
        data: body,
      );
    } on DioException catch (e) {
      log('Erro ao deletar recurso: $e', name: 'ClientHttpService');
      rethrow;
    }
  }

  @override
  Future<Response> patch(String route,
      {required Map<String, dynamic> body}) async {
    try {
      final data = dio.patch(
        route,
        data: body,
      );

      return data;
    } on DioException catch (e) {
      log('PATCH request failed for route: $route, Error: $e',
          name: 'ClientHttpService');
      return Response(
        statusMessage:
            "{\"data\": null, \"message\": \"Ocorreu um erro interno\"}",
        statusCode: e.response?.statusCode ?? 500,
        requestOptions: RequestOptions(),
      );
    }
  }
}
