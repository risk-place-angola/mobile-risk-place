// ignore_for_file: constant_identifier_names
import 'package:firebase_database/firebase_database.dart';

class BDCollections {
  static const String USERS = "users";
  static const String ERFCE = "erfce";
  static const String WARNINGS = "erfce_warns";
}

abstract class IDBHelper {
  Future<void> setData(
      {required String collection, Map<String, dynamic>? value});
  Future<void> updateData(
      {required String collection, Map<String, dynamic>? value});
  Future<void> deleteData(
      {required String collection, Map<String, dynamic>? value});
  Future<dynamic> getData(
      {required String collection, Map<String, dynamic>? value});
}

class DBHelper implements IDBHelper {
  DBHelper._();
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  static final instance = DBHelper._();

  @override
  Future<void> setData(
      {required String collection, Map<String, dynamic>? value}) async {
    bool isExist = false;

    if (!isExist) {
      return database.child(collection).push().set(value);
    }
  }

  @override
  Future<void> deleteData(
      {required String collection, Map<String, dynamic>? value}) {
    return database.child(collection).remove();
  }

  @override
  Future<dynamic> getData(
      {required String collection, Map<String, dynamic>? value}) {
    return database.child(collection).once();
  }

  @override
  Future<void> updateData(
      {required String collection, Map<String, dynamic>? value}) {
    return database.child(collection).update(value!);
  }
}
