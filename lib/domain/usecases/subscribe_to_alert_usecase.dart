import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/repositories/alert_repository.dart';
import 'package:rpa/data/repositories/alert_repository_impl.dart';

final subscribeToAlertUseCaseProvider =
    Provider<SubscribeToAlertUseCase>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return SubscribeToAlertUseCase(repository: repository);
});

class SubscribeToAlertUseCase {
  final IAlertRepository _repository;

  SubscribeToAlertUseCase({required IAlertRepository repository})
      : _repository = repository;

  Future<void> execute(String alertId) async {
    try {
      log('Subscribing to alert: $alertId', name: 'SubscribeToAlertUseCase');
      await _repository.subscribeToAlert(alertId);
      log('Successfully subscribed', name: 'SubscribeToAlertUseCase');
    } catch (e) {
      log('Error subscribing to alert: $e', name: 'SubscribeToAlertUseCase');
      rethrow;
    }
  }
}
