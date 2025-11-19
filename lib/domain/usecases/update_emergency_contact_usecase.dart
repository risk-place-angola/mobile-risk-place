import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/emergency_contact.dart';
import 'package:rpa/domain/repositories/emergency_contact_repository.dart';
import 'package:rpa/data/repositories/emergency_contact_repository_impl.dart';

final updateEmergencyContactUseCaseProvider = Provider<UpdateEmergencyContactUseCase>((ref) {
  final repository = ref.watch(emergencyContactRepositoryProvider);
  return UpdateEmergencyContactUseCase(repository: repository);
});

class UpdateEmergencyContactUseCase {
  final IEmergencyContactRepository _repository;

  UpdateEmergencyContactUseCase({required IEmergencyContactRepository repository})
      : _repository = repository;

  Future<EmergencyContact> execute({
    required String id,
    required String name,
    required String phone,
    required ContactRelation relation,
    required bool isPriority,
  }) async {
    try {
      log('Updating emergency contact: $id', name: 'UpdateEmergencyContactUseCase');
      
      if (name.trim().isEmpty) {
        throw Exception('Nome é obrigatório');
      }
      
      if (phone.trim().isEmpty) {
        throw Exception('Telefone é obrigatório');
      }
      
      final contact = await _repository.updateContact(
        id: id,
        name: name,
        phone: phone,
        relation: relation,
        isPriority: isPriority,
      );
      
      log('Contact updated successfully: ${contact.id}', name: 'UpdateEmergencyContactUseCase');
      return contact;
    } catch (e) {
      log('Error updating contact: $e', name: 'UpdateEmergencyContactUseCase');
      rethrow;
    }
  }
}
