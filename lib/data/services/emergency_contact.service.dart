import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/domain/entities/emergency_contact.dart';
import 'package:rpa/domain/usecases/get_emergency_contacts_usecase.dart';
import 'package:rpa/domain/usecases/create_emergency_contact_usecase.dart';
import 'package:rpa/domain/usecases/update_emergency_contact_usecase.dart';
import 'package:rpa/domain/usecases/delete_emergency_contact_usecase.dart';
import 'package:rpa/domain/usecases/send_emergency_alert_usecase.dart';

final emergencyContactServiceProvider =
    Provider<EmergencyContactService>((ref) {
  return EmergencyContactService(
    getContactsUseCase: ref.watch(getEmergencyContactsUseCaseProvider),
    createContactUseCase: ref.watch(createEmergencyContactUseCaseProvider),
    updateContactUseCase: ref.watch(updateEmergencyContactUseCaseProvider),
    deleteContactUseCase: ref.watch(deleteEmergencyContactUseCaseProvider),
    sendAlertUseCase: ref.watch(sendEmergencyAlertUseCaseProvider),
  );
});

class EmergencyContactService {
  final GetEmergencyContactsUseCase _getContactsUseCase;
  final CreateEmergencyContactUseCase _createContactUseCase;
  final UpdateEmergencyContactUseCase _updateContactUseCase;
  final DeleteEmergencyContactUseCase _deleteContactUseCase;
  final SendEmergencyAlertUseCase _sendAlertUseCase;

  List<EmergencyContact>? _cachedContacts;

  EmergencyContactService({
    required GetEmergencyContactsUseCase getContactsUseCase,
    required CreateEmergencyContactUseCase createContactUseCase,
    required UpdateEmergencyContactUseCase updateContactUseCase,
    required DeleteEmergencyContactUseCase deleteContactUseCase,
    required SendEmergencyAlertUseCase sendAlertUseCase,
  })  : _getContactsUseCase = getContactsUseCase,
        _createContactUseCase = createContactUseCase,
        _updateContactUseCase = updateContactUseCase,
        _deleteContactUseCase = deleteContactUseCase,
        _sendAlertUseCase = sendAlertUseCase;

  Future<List<EmergencyContact>> getContacts(
      {bool forceRefresh = false}) async {
    try {
      if (_cachedContacts != null && !forceRefresh) {
        log('Returning cached contacts', name: 'EmergencyContactService');
        return _cachedContacts!;
      }

      log('Fetching contacts from use case', name: 'EmergencyContactService');
      final contacts = await _getContactsUseCase.execute();
      _cachedContacts = contacts;
      return contacts;
    } catch (e) {
      log('Error in getContacts: $e', name: 'EmergencyContactService');
      rethrow;
    }
  }

  Future<EmergencyContact> createContact({
    required String name,
    required String phone,
    required ContactRelation relation,
    required bool isPriority,
  }) async {
    try {
      log('Creating contact via service', name: 'EmergencyContactService');
      final contact = await _createContactUseCase.execute(
        name: name,
        phone: phone,
        relation: relation,
        isPriority: isPriority,
      );
      _cachedContacts = null;
      return contact;
    } catch (e) {
      log('Error in createContact: $e', name: 'EmergencyContactService');
      rethrow;
    }
  }

  Future<EmergencyContact> updateContact({
    required String id,
    required String name,
    required String phone,
    required ContactRelation relation,
    required bool isPriority,
  }) async {
    try {
      log('Updating contact via service', name: 'EmergencyContactService');
      final contact = await _updateContactUseCase.execute(
        id: id,
        name: name,
        phone: phone,
        relation: relation,
        isPriority: isPriority,
      );
      _cachedContacts = null;
      return contact;
    } catch (e) {
      log('Error in updateContact: $e', name: 'EmergencyContactService');
      rethrow;
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      log('Deleting contact via service', name: 'EmergencyContactService');
      await _deleteContactUseCase.execute(id);
      _cachedContacts = null;
    } catch (e) {
      log('Error in deleteContact: $e', name: 'EmergencyContactService');
      rethrow;
    }
  }

  Future<void> sendEmergencyAlert({
    required double latitude,
    required double longitude,
    String? message,
  }) async {
    try {
      log('Sending emergency alert via service',
          name: 'EmergencyContactService');
      await _sendAlertUseCase.execute(
        latitude: latitude,
        longitude: longitude,
        message: message,
      );
    } catch (e) {
      log('Error in sendEmergencyAlert: $e', name: 'EmergencyContactService');
      rethrow;
    }
  }

  List<EmergencyContact> getPriorityContacts() {
    if (_cachedContacts == null) return [];
    return _cachedContacts!.where((contact) => contact.isPriority).toList();
  }

  void clearCache() {
    _cachedContacts = null;
  }
}
