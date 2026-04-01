import 'package:hive_flutter/hive_flutter.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/models/activity_event.dart';

/// Hive box names — per 05_DATA_MODEL.md §11.
const String kShiftSessionBoxName = 'mdt_shift_session';
const String kActivityEventsBoxName = 'mdt_activity_events';

/// Key used to store the single active shift session.
const String kActiveShiftKey = 'active_shift';

/// Initialize Hive and register all type adapters.
Future<void> initHiveStorage() async {
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ShiftSessionAdapter());
  Hive.registerAdapter(ActivityEventAdapter());

  // Open boxes
  await Hive.openBox<ShiftSession>(kShiftSessionBoxName);
  await Hive.openBox<ActivityEvent>(kActivityEventsBoxName);
}

/// Get the ShiftSession box.
Box<ShiftSession> getShiftSessionBox() {
  return Hive.box<ShiftSession>(kShiftSessionBoxName);
}

/// Get the ActivityEvent box.
Box<ActivityEvent> getActivityEventsBox() {
  return Hive.box<ActivityEvent>(kActivityEventsBoxName);
}
