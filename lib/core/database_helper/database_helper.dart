// ignore_for_file: constant_identifier_names
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:rpa/core/local_storage/hive_config.dart';

final dbHelperProvider = Provider<IDBHelper>((ref) {
  return DBHelper.instance;
});

class BDCollections {
  static const String USERS = "users";
  static const String ERFCE = "erfce";
  static const String WARNINGS = "erfce_warns";
}

abstract class IDBHelper {
  Future<void> setData(
      {required String collection, required String key, dynamic value});
  Future<void> updateData(
      {required String collection, required String key, dynamic value});
  Future<void> deleteData({required String collection, required String key});
  Future<dynamic> getData({required String collection, required String key});
}

class DBHelper implements IDBHelper {
  DBHelper._();
  static final instance = DBHelper._();

  @override
  Future<void> setData(
      {required String collection, required String key, dynamic value}) async {
    final box = await Hive.openBox(collection);
    return box.put(key, value);
  }

  @override
  Future<void> deleteData(
      {required String collection, required String key}) async {
    final box = await Hive.openBox(collection);
    if (!box.containsKey(key)) {
      box.deleteFromDisk();
      await HiveConfig.initialize();
    }
    return box.delete(key);
  }

  @override
  Future<dynamic> getData(
      {required String collection, required String key}) async {
    final box = await Hive.openBox(collection);
    return box.get(key);
  }

  @override
  Future<void> updateData(
      {required String collection, required String key, dynamic value}) async {
    final box = await Hive.openBox(collection);
    return box.put(key, value);
  }
}
