import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/data/dtos/alert_dto.dart';
import 'package:rpa/domain/entities/user_alert.dart';
import 'package:rpa/domain/usecases/get_my_alerts_usecase.dart';
import 'package:rpa/domain/usecases/get_subscribed_alerts_usecase.dart';
import 'package:rpa/domain/usecases/update_alert_usecase.dart';
import 'package:rpa/domain/usecases/delete_alert_usecase.dart';
import 'package:rpa/domain/usecases/subscribe_to_alert_usecase.dart';
import 'package:rpa/domain/usecases/unsubscribe_from_alert_usecase.dart';

final alertServiceProvider = Provider<AlertService>((ref) {
  final httpClient = ref.read(httpClientProvider);
  return AlertService(
    httpClient: httpClient,
    getMyAlertsUseCase: ref.watch(getMyAlertsUseCaseProvider),
    getSubscribedAlertsUseCase: ref.watch(getSubscribedAlertsUseCaseProvider),
    updateAlertUseCase: ref.watch(updateAlertUseCaseProvider),
    deleteAlertUseCase: ref.watch(deleteAlertUseCaseProvider),
    subscribeToAlertUseCase: ref.watch(subscribeToAlertUseCaseProvider),
    unsubscribeFromAlertUseCase: ref.watch(unsubscribeFromAlertUseCaseProvider),
  );
});

/// Service to create and manage alerts
class AlertService {
  final IHttpClient _httpClient;
  final GetMyAlertsUseCase _getMyAlertsUseCase;
  final GetSubscribedAlertsUseCase _getSubscribedAlertsUseCase;
  final UpdateAlertUseCase _updateAlertUseCase;
  final DeleteAlertUseCase _deleteAlertUseCase;
  final SubscribeToAlertUseCase _subscribeToAlertUseCase;
  final UnsubscribeFromAlertUseCase _unsubscribeFromAlertUseCase;

  List<UserAlert>? _cachedMyAlerts;
  List<UserAlert>? _cachedSubscribedAlerts;

  AlertService({
    required IHttpClient httpClient,
    required GetMyAlertsUseCase getMyAlertsUseCase,
    required GetSubscribedAlertsUseCase getSubscribedAlertsUseCase,
    required UpdateAlertUseCase updateAlertUseCase,
    required DeleteAlertUseCase deleteAlertUseCase,
    required SubscribeToAlertUseCase subscribeToAlertUseCase,
    required UnsubscribeFromAlertUseCase unsubscribeFromAlertUseCase,
  })  : _httpClient = httpClient,
        _getMyAlertsUseCase = getMyAlertsUseCase,
        _getSubscribedAlertsUseCase = getSubscribedAlertsUseCase,
        _updateAlertUseCase = updateAlertUseCase,
        _deleteAlertUseCase = deleteAlertUseCase,
        _subscribeToAlertUseCase = subscribeToAlertUseCase,
        _unsubscribeFromAlertUseCase = unsubscribeFromAlertUseCase;

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

      // If we get here, request was successful (200-299)
      if (response.data == null) {
        throw ServerException(message: 'Empty response from server');
      }
      
      log('Alert created successfully: ${response.data['status']}',
          name: 'AlertService');
      return true;
    } on HttpException {
      rethrow;
    } catch (e) {
      log('Unexpected error creating alert: $e', name: 'AlertService');
      throw ServerException(message: 'Erro inesperado ao criar alerta');
    }
  }

  Future<List<UserAlert>> getMyAlerts({bool forceRefresh = false}) async {
    try {
      if (_cachedMyAlerts != null && !forceRefresh) {
        log('Returning cached my alerts', name: 'AlertService');
        return _cachedMyAlerts!;
      }

      log('Fetching my alerts from use case', name: 'AlertService');
      final alerts = await _getMyAlertsUseCase.execute();
      _cachedMyAlerts = alerts;
      return alerts;
    } on UnauthorizedException {
      // Anonymous users can't have created alerts
      log('Anonymous user - returning empty my alerts', name: 'AlertService');
      return [];
    } catch (e) {
      log('Error in getMyAlerts: $e', name: 'AlertService');
      if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        return [];
      }
      rethrow;
    }
  }

  Future<List<UserAlert>> getSubscribedAlerts(
      {bool forceRefresh = false}) async {
    try {
      if (_cachedSubscribedAlerts != null && !forceRefresh) {
        log('Returning cached subscribed alerts', name: 'AlertService');
        return _cachedSubscribedAlerts!;
      }

      log('Fetching subscribed alerts from use case', name: 'AlertService');
      final alerts = await _getSubscribedAlertsUseCase.execute();
      _cachedSubscribedAlerts = alerts;
      return alerts;
    } on UnauthorizedException {
      // Anonymous users can't have subscribed alerts
      log('Anonymous user - returning empty subscribed alerts', name: 'AlertService');
      return [];
    } catch (e) {
      log('Error in getSubscribedAlerts: $e', name: 'AlertService');
      if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        return [];
      }
      rethrow;
    }
  }

  Future<UserAlert> updateAlert({
    required String alertId,
    required String message,
    required AlertSeverity severity,
    required int radiusMeters,
  }) async {
    try {
      log('Updating alert via service', name: 'AlertService');
      final alert = await _updateAlertUseCase.execute(
        alertId: alertId,
        message: message,
        severity: severity,
        radiusMeters: radiusMeters,
      );
      _cachedMyAlerts = null;
      return alert;
    } catch (e) {
      log('Error in updateAlert: $e', name: 'AlertService');
      rethrow;
    }
  }

  Future<void> deleteAlert(String alertId) async {
    try {
      log('Deleting alert via service', name: 'AlertService');
      await _deleteAlertUseCase.execute(alertId);
      _cachedMyAlerts = null;
    } catch (e) {
      log('Error in deleteAlert: $e', name: 'AlertService');
      rethrow;
    }
  }

  Future<void> subscribeToAlert(String alertId) async {
    try {
      log('Subscribing to alert via service', name: 'AlertService');
      await _subscribeToAlertUseCase.execute(alertId);
      _cachedSubscribedAlerts = null;
    } catch (e) {
      log('Error in subscribeToAlert: $e', name: 'AlertService');
      rethrow;
    }
  }

  Future<void> unsubscribeFromAlert(String alertId) async {
    try {
      log('Unsubscribing from alert via service', name: 'AlertService');
      await _unsubscribeFromAlertUseCase.execute(alertId);
      _cachedSubscribedAlerts = null;
    } catch (e) {
      log('Error in unsubscribeFromAlert: $e', name: 'AlertService');
      rethrow;
    }
  }

  void clearCache() {
    _cachedMyAlerts = null;
    _cachedSubscribedAlerts = null;
  }
}
