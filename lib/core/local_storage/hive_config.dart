import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rpa/data/models/user.model.dart';

class HiveConfig {
  static Future<void> initialize() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    Hive.registerAdapter(UserAdapter());

    await Hive.openBox(HiveBoxs.USERBOX);
  }

  static void dispose() {
    Hive.close();
  }
}

abstract class HiveBoxs {
  static const String USERBOX = "user_box";
  static const String WARNINGSBOX = "warnings_box";
}