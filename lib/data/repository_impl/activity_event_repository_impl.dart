import 'package:ptba_mdt/data/local_storage/hive_storage.dart';
import 'package:ptba_mdt/domain/models/activity_event.dart';
import 'package:ptba_mdt/domain/repositories/activity_event_repository.dart';

/// Hive-backed implementation of [ActivityEventRepository].
class ActivityEventRepositoryImpl implements ActivityEventRepository {
  @override
  Future<void> appendEvent(ActivityEvent event) async {
    final box = getActivityEventsBox();
    await box.add(event);
  }

  @override
  Future<List<ActivityEvent>> getEventsByShift(String shiftSessionId) async {
    final box = getActivityEventsBox();
    final events = box.values
        .where((e) => e.shiftSessionId == shiftSessionId)
        .toList();
    // Sort by occurredAt to guarantee order.
    events.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return events;
  }

  @override
  Future<ActivityEvent?> getCurrentActiveActivity(
      String shiftSessionId) async {
    final events = await getEventsByShift(shiftSessionId);

    // Walk backwards to find the most recent ACTIVITY_STARTED
    // that has no matching ACTIVITY_ENDED after it.
    ActivityEvent? lastStarted;
    for (final event in events.reversed) {
      if (event.eventName == 'ACTIVITY_ENDED' ||
          event.eventName == 'SHIFT_ENDED') {
        // The latest activity has already ended.
        return null;
      }
      if (event.eventName == 'ACTIVITY_STARTED') {
        lastStarted = event;
        break;
      }
    }
    return lastStarted;
  }

  @override
  Future<void> clearEvents() async {
    final box = getActivityEventsBox();
    await box.clear();
  }
}
