import 'package:ptba_mdt/domain/models/activity_event.dart';

/// Repository interface for ActivityEvent persistence.
/// Per 05_DATA_MODEL.md §12 and 06_ARCHITECTURE.md §4.4.
abstract class ActivityEventRepository {
  /// Append a new event (append-only).
  Future<void> appendEvent(ActivityEvent event);

  /// Get all events for a given shift session, ordered by occurredAt.
  Future<List<ActivityEvent>> getEventsByShift(String shiftSessionId);

  /// Get the most recent ACTIVITY_STARTED event without a matching
  /// ACTIVITY_ENDED, i.e. the currently running activity.
  Future<ActivityEvent?> getCurrentActiveActivity(String shiftSessionId);

  /// Clear all stored events.
  Future<void> clearEvents();
}
