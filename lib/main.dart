import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rpa/core/local_storage/hive_config.dart';
import 'package:rpa/firebase_options.dart';

import 'app_widget.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    final firebaseName = 'MakaNetu';
    await Firebase.initializeApp(
      name: firebaseName,
      options: DefaultFirebaseOptions.currentPlatform,
    );

    //Hive Configurations for local storage
    await HiveConfig.initialize();

    // await AppCenter.start("306f3ea0-8ecb-4004-90b5-8c06619545f5",
    //     [AppCenterAnalytics.id, AppCenterCrashes.id]);

    // Map<Permission, PermissionStatus> statuses = await [
    //   Permission.microphone,
    //   Permission.storage,
    // ].request();

    runApp(
      ProviderScope(
        child: AppWidget(),
      ),
    );
  } catch (e) {
    print("Erro ao inicializar o Firebase: $e");
  }
}
