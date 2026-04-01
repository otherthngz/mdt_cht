import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ptba_mdt/app/app.dart';
import 'package:ptba_mdt/data/local_storage/hive_storage.dart';
import 'package:ptba_mdt/data/repository_impl/shift_repository_impl.dart';
import 'package:ptba_mdt/data/repository_impl/activity_event_repository_impl.dart';
import 'package:ptba_mdt/features/shift/shift_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive + register adapters + open boxes.
  await initHiveStorage();

  runApp(
    ProviderScope(
      overrides: [
        // Inject repository implementations.
        shiftRepositoryProvider.overrideWithValue(
          ShiftRepositoryImpl(),
        ),
        activityEventRepositoryProvider.overrideWithValue(
          ActivityEventRepositoryImpl(),
        ),
      ],
      child: const MdtApp(),
    ),
  );
}
