import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/emergency_contact.dart';
import 'package:rpa/domain/repositories/emergency_contact_repository.dart';
import 'package:rpa/data/repositories/emergency_contact_repository_impl.dart';

final getEmergencyContactsUseCaseProvider =
    Provider<GetEmergencyContactsUseCase>((ref) {
  final repository = ref.watch(emergencyContactRepositoryProvider);
  return GetEmergencyContactsUseCase(repository: repository);
});

class GetEmergencyContactsUseCase {
  final IEmergencyContactRepository _repository;

  GetEmergencyContactsUseCase({required IEmergencyContactRepository repository})
      : _repository = repository;

  Future<List<EmergencyContact>> execute() async {
    try {
      log('Fetching emergency contacts...',
          name: 'GetEmergencyContactsUseCase');
      final contacts = await _repository.getContacts();
      log('Retrieved ${contacts.length} contacts',
          name: 'GetEmergencyContactsUseCase');
      return contacts;
    } catch (e) {
      log('Error fetching contacts: $e', name: 'GetEmergencyContactsUseCase');
      rethrow;
    }
  }
}
