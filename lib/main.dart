import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rpa/core/local_storage/hive_config.dart';
import 'package:rpa/firebase_options.dart';
import 'package:rpa/presenter/pages/login/login.page.dart';
import 'package:rpa/presenter/pages/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Hive Configurations for local storage
  await Hive.initFlutter();

  HiveConfig.initialize();

  // await AppCenter.start("306f3ea0-8ecb-4004-90b5-8c06619545f5",
  //     [AppCenterAnalytics.id, AppCenterCrashes.id]);

  Map<Permission, PermissionStatus> statuses = await [
    Permission.microphone,
    Permission.storage,
  ].request();
  runApp(
    ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: const ColorScheme(
        background: Colors.white,
        brightness: Brightness.light,
        error: Colors.red,
        onBackground: Colors.grey,
        onError: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.grey,
        primary: Color(0xCC376E76),
        secondary: Color.fromARGB(255, 58, 139, 152),
        surface: Colors.grey,
      )),
      home: const SplashPage(),
    );
  }
}
