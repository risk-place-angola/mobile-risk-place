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

    await dotenv.load(fileName: ".env");

    final firebaseName = 'MakaNetu';
    await Firebase.initializeApp(
      name: firebaseName,
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await HiveConfig.initialize();

    runApp(
      ProviderScope(
        child: AppWidget(),
      ),
    );
  } catch (e) {
    print("Erro ao inicializar o Firebase: $e");
  }
}
