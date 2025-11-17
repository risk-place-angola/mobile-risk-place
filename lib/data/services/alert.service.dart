import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/dtos/alert_dto.dart';

final alertServiceProvider = Provider<AlertService>((ref) {
  final httpClient = ref.read(httpClientProvider);
  return AlertService(httpClient: httpClient);
});

/// Service to create and manage alerts
class AlertService {
  final IHttpClient _httpClient;

  AlertService({required IHttpClient httpClient}) : _httpClient = httpClient;

  /// Create a new alert (emergency broadcast)
  /// 
  /// Note: Requires special permissions (authority, government, admin)
  Future<bool> createAlert({
    required CreateAlertRequestDTO alertData,
  }) async {
    try {
      log('Creating alert...', name: 'AlertService');
      
      final response = await _httpClient.post(
        '/alerts',
        data: alertData.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        log('Alert created successfully: ${response.data['status']}', name: 'AlertService');
        return true;
      } else {
        throw ServerException(
          message: 'Falha ao criar alerta',
          statusCode: response.statusCode,
        );
      }
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error creating alert: $e', name: 'AlertService');
      throw ServerException(message: 'Erro inesperado ao criar alerta');
    }
  }
}
