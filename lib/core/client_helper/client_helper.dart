import 'dart:developer';
import 'package:dio/dio.dart';

abstract class Endpoints {
  static const String LOGIN = "/user/login";
  static const String REGISTER = "/user";
  static const String LOGOUT = "/auth/logout";
  static const String WARNING = "/warning";
}

class HTTPClient implements Endpoints {
  static BaseOptions options = BaseOptions(
    baseUrl: "https://risk-place-angola.onrender.com/api/v1",
    connectTimeout: const Duration(milliseconds: 15000),
    receiveTimeout: const Duration(milliseconds: 13000),
  );
  Dio dio = Dio(options);

  Future get(String url, {Map<String, String>? headers}) async {
    try {
      var response = await dio.get(url, options: Options(headers: headers));
      log(response.data.toString());
      return response.data;
    } on DioException catch (e) {
      log(e.toString());
    }
  }

  Future post(String url, {Map<String, String>? headers, dynamic body}) async {
    try {
      var response =
          await dio.post(url, options: Options(headers: headers), data: body);
      log(response.data.toString());
      return response.data;
    } on DioException catch (e) {
      log(e.message.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  Future delete(String url,
      {Map<String, String>? headers, dynamic body}) async {
    try {
      var response =
          await dio.delete(url, options: Options(headers: headers), data: body);
      log(response.data.toString());
      return response.data;
    } on DioException catch (e) {
      log(e.toString());
    }
  }

  Future update(String url,
      {Map<String, String>? headers, dynamic body}) async {
    try {
      var response =
          await dio.patch(url, options: Options(headers: headers), data: body);
      log(response.data.toString());
      return response.data;
    } on DioException catch (e) {
      log(e.toString());
    }
  }
}
