import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/domain/entities/user_alert.dart';
import 'package:rpa/domain/repositories/alert_repository.dart';
import 'package:rpa/data/models/user_alert_dto.dart';

final alertRepositoryProvider = Provider<IAlertRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return AlertRepositoryImpl(httpClient: httpClient);
});

class AlertRepositoryImpl implements IAlertRepository {
  final IHttpClient _httpClient;

  AlertRepositoryImpl({required IHttpClient httpClient})
      : _httpClient = httpClient;

  @override
  Future<List<UserAlert>> getMyAlerts() async {
    try {
      log('Fetching my created alerts from API...', name: 'AlertRepository');

      final response = await _httpClient.get('/users/me/alerts/created');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> alertsJson = response.data as List;
        final alerts = alertsJson
            .map((json) => UserAlertDto.fromJson(json).toEntity())
            .toList();

        log('Retrieved ${alerts.length} created alerts',
            name: 'AlertRepository');
        return alerts;
      } else {
        throw ServerException(
          message: 'Falha ao carregar alertas',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error fetching my alerts: $e', name: 'AlertRepository');
      rethrow;
    }
  }

  @override
  Future<List<UserAlert>> getSubscribedAlerts() async {
    try {
      log('Fetching subscribed alerts from API...', name: 'AlertRepository');

      final response = await _httpClient.get('/users/me/alerts/subscribed');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> alertsJson = response.data as List;
        final alerts = alertsJson
            .map((json) => UserAlertDto.fromJson(json).toEntity())
            .toList();

        log('Retrieved ${alerts.length} subscribed alerts',
            name: 'AlertRepository');
        return alerts;
      } else {
        throw ServerException(
          message: 'Falha ao carregar alertas inscritos',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error fetching subscribed alerts: $e', name: 'AlertRepository');
      rethrow;
    }
  }

  @override
  Future<UserAlert> updateAlert({
    required String alertId,
    required String message,
    required AlertSeverity severity,
    required int radiusMeters,
  }) async {
    try {
      log('Updating alert: $alertId', name: 'AlertRepository');

      final data = {
        'message': message,
        'severity': severity.name,
        'radius_meters': radiusMeters,
      };

      final response = await _httpClient.put('/alerts/$alertId', data: data);

      if (response.statusCode == 200 && response.data != null) {
        final alert = UserAlertDto.fromJson(response.data).toEntity();
        log('Alert updated successfully', name: 'AlertRepository');
        return alert;
      } else {
        throw ServerException(
          message: response.data?['error'] ?? 'Falha ao atualizar alerta',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error updating alert: $e', name: 'AlertRepository');
      rethrow;
    }
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    try {
      log('Deleting alert: $alertId', name: 'AlertRepository');

      final response = await _httpClient.delete('/alerts/$alertId');

      if (response.statusCode == 204 || response.statusCode == 200) {
        log('Alert deleted successfully', name: 'AlertRepository');
      } else {
        throw ServerException(
          message: response.data?['error'] ?? 'Falha ao deletar alerta',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error deleting alert: $e', name: 'AlertRepository');
      rethrow;
    }
  }

  @override
  Future<void> subscribeToAlert(String alertId) async {
    try {
      log('Subscribing to alert: $alertId', name: 'AlertRepository');

      final response = await _httpClient.post('/alerts/$alertId/subscribe');

      if (response.statusCode == 200) {
        log('Successfully subscribed to alert', name: 'AlertRepository');
      } else {
        throw ServerException(
          message: response.data?['error'] ?? 'Falha ao inscrever no alerta',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error subscribing to alert: $e', name: 'AlertRepository');
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromAlert(String alertId) async {
    try {
      log('Unsubscribing from alert: $alertId', name: 'AlertRepository');

      final response = await _httpClient.delete('/alerts/$alertId/unsubscribe');

      if (response.statusCode == 200) {
        log('Successfully unsubscribed from alert', name: 'AlertRepository');
      } else {
        throw ServerException(
          message: response.data?['error'] ?? 'Falha ao cancelar inscrição',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error unsubscribing from alert: $e', name: 'AlertRepository');
      rethrow;
    }
  }
}
