// ignore_for_file: constant_identifier_names
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rpa/core/database_helper/database_helper.dart';

abstract class IStorage {
  Future<void> sendFile({File? file});
  Future<void> updateFile({File? file});
  Future<void> deleteFile({File? file});
  Future<dynamic> getFile({File? file});
  Future<List<dynamic>> getFiles({File? file});
}

class Storage implements IStorage {
  Storage._();
  final bucket = FirebaseStorage.instance.ref(BDCollections.WARNINGS);
  static final instance = Storage._();

  @override
  Future<void> deleteFile({File? file}) {
    throw UnimplementedError();
  }

  @override
  Future getFile({File? file}) {
    throw UnimplementedError();
  }

  @override
  Future<List> getFiles({File? file}) {
    throw UnimplementedError();
  }

  @override
  Future<String> sendFile({File? file}) async {
    final ref = bucket.child(file!.path);
    return await ref.putFile(file).then((value) => value.ref.getDownloadURL());
  }

  @override
  Future<void> updateFile({File? file}) {
    throw UnimplementedError();
  }
}
