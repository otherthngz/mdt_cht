import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Platform-specific database opener — web.
/// Uses sql.js loaded from CDN — no extra setup needed.
Future<QueryExecutor> openPlatformExecutor() async {
  return WebDatabase('mdt_poc');
}
