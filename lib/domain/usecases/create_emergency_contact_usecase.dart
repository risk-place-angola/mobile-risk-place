import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/emergency_contact.dart';
import 'package:rpa/domain/repositories/emergency_contact_repository.dart';
import 'package:rpa/data/repositories/emergency_contact_repository_impl.dart';

final createEmergencyContactUseCaseProvider = Provider<CreateEmergencyContactUseCase>((ref) {
  final repository = ref.watch(emergencyContactRepositoryProvider);
  return CreateEmergencyContactUseCase(repository: repository);
});

class CreateEmergencyContactUseCase {
  final IEmergencyContactRepository _repository;

  CreateEmergencyContactUseCase({required IEmergencyContactRepository repository})
      : _repository = repository;

  Future<EmergencyContact> execute({
    required String name,
    required String phone,
    required ContactRelation relation,
    required bool isPriority,
  }) async {
    try {
      log('Creating emergency contact: $name', name: 'CreateEmergencyContactUseCase');
      
      if (name.trim().isEmpty) {
        throw Exception('Nome é obrigatório');
      }
      
      if (phone.trim().isEmpty) {
        throw Exception('Telefone é obrigatório');
      }
      
      final contact = await _repository.createContact(
        name: name,
        phone: phone,
        relation: relation,
        isPriority: isPriority,
      );
      
      log('Contact created successfully: ${contact.id}', name: 'CreateEmergencyContactUseCase');
      return contact;
    } catch (e) {
      log('Error creating contact: $e', name: 'CreateEmergencyContactUseCase');
      rethrow;
    }
  }
}
