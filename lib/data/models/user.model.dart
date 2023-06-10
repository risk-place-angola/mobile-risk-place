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
  String? createdAt;
  @HiveField(6)
  bool? isRFCE;
  @HiveField(7)
  String? token;

  User(
      {this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.password,
      this.createdAt,
      this.token,
      this.isRFCE});

  factory User.fromJson(var json) {
    return User(
      id: json['id'] != null ? json['id'] : null,
      name: json['name'] != null ? json['name'] : null,
      email: json['email'] != null ? json['email'] : null,
      phoneNumber: json['phone_number'] != null ? json['phone_number'] : null,
      password: json['password'] != null ? json['password'] : null,
      isRFCE: json['is_rfce'] != null ? json['is_rfce'] : null,
      token: json['token'] != null ? json['token'] : null,
      createdAt: json['created_at'] != null ? json['created_at'] : null,
    );
  }

  factory User.fromLogin(var json) {
    return User(
      token: json['token'] != null ? json['token'] : null,
    );
  }

  Map<String, dynamic> registerUser() => {
        'name': name,
        'email': email,
        'phone': phoneNumber,
        'password': password,
      };
  Map<String, dynamic> toJsonIsRFCE() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'created_at': createdAt,
        'is_rfce': isRFCE
      };

  Map<String, dynamic> toLoginUser() => {'email': email, 'password': password};
}
