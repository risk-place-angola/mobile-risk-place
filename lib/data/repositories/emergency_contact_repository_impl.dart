import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpa/core/http_client/i_http_client.dart';
import 'package:rpa/core/http_client/dio_http_client.dart';
import 'package:rpa/core/http_client/exceptions/http_exceptions.dart';
import 'package:rpa/domain/entities/emergency_contact.dart';
import 'package:rpa/domain/repositories/emergency_contact_repository.dart';
import 'package:rpa/data/models/emergency_contact_dto.dart';

final emergencyContactRepositoryProvider = Provider<IEmergencyContactRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return EmergencyContactRepositoryImpl(httpClient: httpClient);
});

class EmergencyContactRepositoryImpl implements IEmergencyContactRepository {
  final IHttpClient _httpClient;

  EmergencyContactRepositoryImpl({required IHttpClient httpClient})
      : _httpClient = httpClient;

  @override
  Future<List<EmergencyContact>> getContacts() async {
    try {
      log('Fetching emergency contacts from API...', name: 'EmergencyContactRepository');

      final response = await _httpClient.get('/users/me/emergency-contacts');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> contactsJson = response.data as List;
        final contacts = contactsJson
            .map((json) => EmergencyContactDto.fromJson(json).toEntity())
            .toList();

        log('Retrieved ${contacts.length} contacts', name: 'EmergencyContactRepository');
        return contacts;
      } else {
        throw ServerException(
          message: 'Falha ao carregar contatos',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error fetching contacts: $e', name: 'EmergencyContactRepository');
      rethrow;
    }
  }

  @override
  Future<EmergencyContact> createContact({
    required String name,
    required String phone,
    required ContactRelation relation,
    required bool isPriority,
  }) async {
    try {
      log('Creating emergency contact: $name', name: 'EmergencyContactRepository');

      final dto = EmergencyContactDto(
        name: name,
        phone: phone,
        relation: relation.name,
        isPriority: isPriority,
      );

      final response = await _httpClient.post(
        '/users/me/emergency-contacts',
        data: dto.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        final contact = EmergencyContactDto.fromJson(response.data).toEntity();
        log('Contact created successfully: ${contact.id}', name: 'EmergencyContactRepository');
        return contact;
      } else {
        throw ServerException(
          message: response.data?['error'] ?? 'Falha ao criar contato',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error creating contact: $e', name: 'EmergencyContactRepository');
      rethrow;
    }
  }

  @override
  Future<EmergencyContact> updateContact({
    required String id,
    required String name,
    required String phone,
    required ContactRelation relation,
    required bool isPriority,
  }) async {
    try {
      log('Updating emergency contact: $id', name: 'EmergencyContactRepository');

      final dto = EmergencyContactDto(
        id: id,
        name: name,
        phone: phone,
        relation: relation.name,
        isPriority: isPriority,
      );

      final response = await _httpClient.put(
        '/users/me/emergency-contacts/$id',
        data: dto.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final contact = EmergencyContactDto.fromJson(response.data).toEntity();
        log('Contact updated successfully', name: 'EmergencyContactRepository');
        return contact;
      } else {
        throw ServerException(
          message: response.data?['error'] ?? 'Falha ao atualizar contato',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error updating contact: $e', name: 'EmergencyContactRepository');
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    try {
      log('Deleting emergency contact: $id', name: 'EmergencyContactRepository');

      final response = await _httpClient.delete('/users/me/emergency-contacts/$id');

      if (response.statusCode == 204 || response.statusCode == 200) {
        log('Contact deleted successfully', name: 'EmergencyContactRepository');
      } else {
        throw ServerException(
          message: response.data?['error'] ?? 'Falha ao deletar contato',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error deleting contact: $e', name: 'EmergencyContactRepository');
      rethrow;
    }
  }

  @override
  Future<void> sendEmergencyAlert({
    required double latitude,
    required double longitude,
    String? message,
  }) async {
    try {
      log('Sending emergency alert to contacts', name: 'EmergencyContactRepository');

      final data = {
        'latitude': latitude,
        'longitude': longitude,
        if (message != null && message.isNotEmpty) 'message': message,
      };

      final response = await _httpClient.post('/emergency/alert', data: data);

      if (response.statusCode == 200) {
        log('Emergency alert sent successfully', name: 'EmergencyContactRepository');
      } else {
        throw ServerException(
          message: response.data?['error'] ?? 'Falha ao enviar alerta',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error sending emergency alert: $e', name: 'EmergencyContactRepository');
      rethrow;
    }
  }
}
