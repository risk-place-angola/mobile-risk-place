// ignore_for_file: prefer_if_null_operators

import 'package:hive_flutter/adapters.dart';
part 'user.model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? email;
  @HiveField(3)
  String? phoneNumber;
  @HiveField(4)
  String? password;
  @HiveField(5)
  DateTime? createdAt;
  @HiveField(6)
  bool? isRFCE;

  User(
      {this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.password,
      this.createdAt,
      this.isRFCE});

  factory User.fromJson(var json) {
    return User(
      id: json['id'] != null ? json['id'] : null,
      name: json['name'] != null ? json['name'] : null,
      email: json['email'] != null ? json['email'] : null,
      phoneNumber: json['phone_number'] != null ? json['phone_number'] : null,
      password: json['password'] != null ? json['password'] : null,
      isRFCE: json['is_rfce'] != null ? json['is_rfce'] : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'created_at': createdAt?.toIso8601String()
      };
  Map<String, dynamic> toJsonIsRFCE() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'created_at': createdAt?.toIso8601String(),
        'is_rfce': isRFCE
      };
}
