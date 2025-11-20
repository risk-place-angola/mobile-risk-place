import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/repositories/emergency_contact_repository.dart';
import 'package:rpa/data/repositories/emergency_contact_repository_impl.dart';

final deleteEmergencyContactUseCaseProvider =
    Provider<DeleteEmergencyContactUseCase>((ref) {
  final repository = ref.watch(emergencyContactRepositoryProvider);
  return DeleteEmergencyContactUseCase(repository: repository);
});

class DeleteEmergencyContactUseCase {
  final IEmergencyContactRepository _repository;

  DeleteEmergencyContactUseCase(
      {required IEmergencyContactRepository repository})
      : _repository = repository;

  Future<void> execute(String id) async {
    try {
      log('Deleting emergency contact: $id',
          name: 'DeleteEmergencyContactUseCase');
      await _repository.deleteContact(id);
      log('Contact deleted successfully',
          name: 'DeleteEmergencyContactUseCase');
    } catch (e) {
      log('Error deleting contact: $e', name: 'DeleteEmergencyContactUseCase');
      rethrow;
    }
  }
}
