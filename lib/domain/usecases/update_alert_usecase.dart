import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/user_alert.dart';
import 'package:rpa/domain/repositories/alert_repository.dart';
import 'package:rpa/data/repositories/alert_repository_impl.dart';

final updateAlertUseCaseProvider = Provider<UpdateAlertUseCase>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return UpdateAlertUseCase(repository: repository);
});

class UpdateAlertUseCase {
  final IAlertRepository _repository;

  UpdateAlertUseCase({required IAlertRepository repository})
      : _repository = repository;

  Future<UserAlert> execute({
    required String alertId,
    required String message,
    required AlertSeverity severity,
    required int radiusMeters,
  }) async {
    try {
      log('Updating alert: $alertId', name: 'UpdateAlertUseCase');

      if (message.trim().isEmpty) {
        throw Exception('Mensagem é obrigatória');
      }

      if (radiusMeters < 100 || radiusMeters > 10000) {
        throw Exception('Raio deve estar entre 100 e 10.000 metros');
      }

      final alert = await _repository.updateAlert(
        alertId: alertId,
        message: message,
        severity: severity,
        radiusMeters: radiusMeters,
      );

      log('Alert updated successfully: ${alert.id}',
          name: 'UpdateAlertUseCase');
      return alert;
    } catch (e) {
      log('Error updating alert: $e', name: 'UpdateAlertUseCase');
      rethrow;
    }
  }
}
