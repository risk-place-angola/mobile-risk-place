import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/repositories/alert_repository.dart';
import 'package:rpa/data/repositories/alert_repository_impl.dart';

final deleteAlertUseCaseProvider = Provider<DeleteAlertUseCase>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return DeleteAlertUseCase(repository: repository);
});

class DeleteAlertUseCase {
  final IAlertRepository _repository;

  DeleteAlertUseCase({required IAlertRepository repository})
      : _repository = repository;

  Future<void> execute(String alertId) async {
    try {
      log('Deleting alert: $alertId', name: 'DeleteAlertUseCase');
      await _repository.deleteAlert(alertId);
      log('Alert deleted successfully', name: 'DeleteAlertUseCase');
    } catch (e) {
      log('Error deleting alert: $e', name: 'DeleteAlertUseCase');
      rethrow;
    }
  }
}
