// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';
import 'package:logging/logging.dart';
import 'package:workout_buddy/services/mock_storage_service.dart';

import 'firebase_options.dart';
import 'main_shell.dart';
import 'services/storage_service.dart';
import 'providers/storage_providers.dart';
import 'theme.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  configureLogging(
    logCallback: (level, msg) => debugPrint('GenUI $level: $msg'),
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  StorageService storageService;

  // Use this version when debugging:
  storageService = MockStorageService.withSeedData();

  // Choose the uncommented version for production:
  // if (kIsWeb) {
  //   final prefs = await SharedPreferences.getInstance();
  //   storageService = SharedPreferencesStorageService(prefs);
  // } else {
  //   final docsDir = await getApplicationDocumentsDirectory();
  //   storageService = FileStorageService(
  //     fs: const LocalFileSystem(),
  //     basePath: docsDir.path,
  //   );
  // }

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Buddy',
      debugShowCheckedModeBanner: false,
      theme: WorkoutBuddyTheme.light,
      darkTheme: WorkoutBuddyTheme.dark,
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}
