import 'package:rpa/data/dtos/auth_request_dto.dart';
import 'package:rpa/data/models/address.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String nif;
  final Address address;
  final List<String> roles;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nif,
    required this.address,
    required this.roles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      nif: json['nif'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
      roles: List<String>.from(json['role_name'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'nif': nif,
      'address': address.toJson(),
      'role_name': roles,
    };
  }

  // from AuthUserSummaryDTO

  factory UserProfile.fromAuthUserSummaryDTO(AuthUserSummaryDTO dto) {
    return UserProfile(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      phone: '', // AuthUserSummaryDTO does not have phone
      nif: '', // AuthUserSummaryDTO does not have nif
      address: const Address(
        zipCode: '',
        country: '',
        municipality: '',
        neighborhood: '',
        province: '',
      ),
      roles: dto.roles,
    );
  }
}
