import 'package:hive_flutter/adapters.dart';
import 'package:rpa/data/models/user.model.dart';

class HiveConfig {
  static void initialize() async {
    Hive.registerAdapter(UserAdapter());

    await Hive.openBox(HiveBoxs.USERBOX);
  }
}

abstract class HiveBoxs {
  static const String USERBOX = "user_box";
  static const String WARNINGSBOX = "warnings_box";
}
