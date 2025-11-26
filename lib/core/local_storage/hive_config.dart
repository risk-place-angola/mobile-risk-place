import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rpa/data/models/user.model.dart';
import 'package:rpa/data/models/safe_place.model.dart';

class HiveConfig {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      await Hive.initFlutter();
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    }

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SafePlaceAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SafePlaceCategoryAdapter());
    }

    if (!Hive.isBoxOpen(HiveBoxs.USERBOX)) {
      await Hive.openBox(HiveBoxs.USERBOX);
    }

    _initialized = true;
  }

  static void dispose() {
    Hive.close();
  }
}

abstract class HiveBoxs {
  static const String USERBOX = "user_box";
  static const String WARNINGSBOX = "warnings_box";
  static const String SAFEPLACESBOX = "safe_places";
}
