import 'package:rpa/domain/entities/emergency_contact.dart';

abstract class IEmergencyContactRepository {
  Future<List<EmergencyContact>> getContacts();
  
  Future<EmergencyContact> createContact({
    required String name,
    required String phone,
    required ContactRelation relation,
    required bool isPriority,
  });
  
  Future<EmergencyContact> updateContact({
    required String id,
    required String name,
    required String phone,
    required ContactRelation relation,
    required bool isPriority,
  });
  
  Future<void> deleteContact(String id);
  
  Future<void> sendEmergencyAlert({
    required double latitude,
    required double longitude,
    String? message,
  });
}
