import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/user_alert.dart';
import 'package:rpa/domain/repositories/alert_repository.dart';
import 'package:rpa/data/repositories/alert_repository_impl.dart';

final getMyAlertsUseCaseProvider = Provider<GetMyAlertsUseCase>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return GetMyAlertsUseCase(repository: repository);
});

class GetMyAlertsUseCase {
  final IAlertRepository _repository;

  GetMyAlertsUseCase({required IAlertRepository repository})
      : _repository = repository;

  Future<List<UserAlert>> execute() async {
    try {
      log('Fetching my alerts...', name: 'GetMyAlertsUseCase');
      final alerts = await _repository.getMyAlerts();
      log('Retrieved ${alerts.length} alerts', name: 'GetMyAlertsUseCase');
      return alerts;
    } catch (e) {
      log('Error fetching my alerts: $e', name: 'GetMyAlertsUseCase');
      rethrow;
    }
  }
}
