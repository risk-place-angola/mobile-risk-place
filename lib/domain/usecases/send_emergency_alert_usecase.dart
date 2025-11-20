import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/repositories/emergency_contact_repository.dart';
import 'package:rpa/data/repositories/emergency_contact_repository_impl.dart';

final sendEmergencyAlertUseCaseProvider =
    Provider<SendEmergencyAlertUseCase>((ref) {
  final repository = ref.watch(emergencyContactRepositoryProvider);
  return SendEmergencyAlertUseCase(repository: repository);
});

class SendEmergencyAlertUseCase {
  final IEmergencyContactRepository _repository;

  SendEmergencyAlertUseCase({required IEmergencyContactRepository repository})
      : _repository = repository;

  Future<void> execute({
    required double latitude,
    required double longitude,
    String? message,
  }) async {
    try {
      log('Sending emergency alert to contacts',
          name: 'SendEmergencyAlertUseCase');

      await _repository.sendEmergencyAlert(
        latitude: latitude,
        longitude: longitude,
        message: message,
      );

      log('Emergency alert sent successfully',
          name: 'SendEmergencyAlertUseCase');
    } catch (e) {
      log('Error sending emergency alert: $e',
          name: 'SendEmergencyAlertUseCase');
      rethrow;
    }
  }
}
