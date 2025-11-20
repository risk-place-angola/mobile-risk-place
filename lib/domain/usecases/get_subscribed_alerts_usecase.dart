import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/user_alert.dart';
import 'package:rpa/domain/repositories/alert_repository.dart';
import 'package:rpa/data/repositories/alert_repository_impl.dart';

final getSubscribedAlertsUseCaseProvider =
    Provider<GetSubscribedAlertsUseCase>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return GetSubscribedAlertsUseCase(repository: repository);
});

class GetSubscribedAlertsUseCase {
  final IAlertRepository _repository;

  GetSubscribedAlertsUseCase({required IAlertRepository repository})
      : _repository = repository;

  Future<List<UserAlert>> execute() async {
    try {
      log('Fetching subscribed alerts...', name: 'GetSubscribedAlertsUseCase');
      final alerts = await _repository.getSubscribedAlerts();
      log('Retrieved ${alerts.length} subscribed alerts',
          name: 'GetSubscribedAlertsUseCase');
      return alerts;
    } catch (e) {
      log('Error fetching subscribed alerts: $e',
          name: 'GetSubscribedAlertsUseCase');
      rethrow;
    }
  }
}
