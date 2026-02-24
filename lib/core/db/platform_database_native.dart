import 'package:drift/drift.dart';

/// Platform-specific database opener — native (mobile/desktop).
/// Uses NativeDatabase with a file on disk.
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<QueryExecutor> openPlatformExecutor() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'mdt_poc.sqlite'));
  return NativeDatabase.createInBackground(file);
}
