import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/repositories/alert_repository.dart';
import 'package:rpa/data/repositories/alert_repository_impl.dart';

final unsubscribeFromAlertUseCaseProvider =
    Provider<UnsubscribeFromAlertUseCase>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return UnsubscribeFromAlertUseCase(repository: repository);
});

class UnsubscribeFromAlertUseCase {
  final IAlertRepository _repository;

  UnsubscribeFromAlertUseCase({required IAlertRepository repository})
      : _repository = repository;

  Future<void> execute(String alertId) async {
    try {
      log('Unsubscribing from alert: $alertId',
          name: 'UnsubscribeFromAlertUseCase');
      await _repository.unsubscribeFromAlert(alertId);
      log('Successfully unsubscribed', name: 'UnsubscribeFromAlertUseCase');
    } catch (e) {
      log('Error unsubscribing from alert: $e',
          name: 'UnsubscribeFromAlertUseCase');
      rethrow;
    }
  }
}
