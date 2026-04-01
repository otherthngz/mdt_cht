import 'package:ptba_mdt/domain/models/activity_event.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/repositories/activity_event_repository.dart';
import 'package:ptba_mdt/domain/repositories/shift_repository.dart';

/// In-memory mock of [ShiftRepository] for testing.
class MockShiftRepository implements ShiftRepository {
  ShiftSession? _session;

  /// Expose for assertions.
  ShiftSession? get stored => _session;

  @override
  Future<void> saveShiftSession(ShiftSession session) async {
    _session = session;
  }

  @override
  Future<ShiftSession?> getActiveShiftSession() async {
    if (_session != null && _session!.status == 'active') {
      return _session;
    }
    return null;
  }

  @override
  Future<void> updateShiftSession(ShiftSession session) async {
    _session = session;
  }

  @override
  Future<ShiftSession?> getLatestShiftSession() async {
    return _session;
  }

  @override
  Future<void> clearShiftSession() async {
    _session = null;
  }
}

/// In-memory mock of [ActivityEventRepository] for testing.
class MockActivityEventRepository implements ActivityEventRepository {
  final List<ActivityEvent> _events = [];

  /// Expose for assertions.
  List<ActivityEvent> get storedEvents => List.unmodifiable(_events);

  @override
  Future<void> appendEvent(ActivityEvent event) async {
    _events.add(event);
  }

  @override
  Future<List<ActivityEvent>> getEventsByShift(String shiftSessionId) async {
    final filtered =
        _events.where((e) => e.shiftSessionId == shiftSessionId).toList();
    filtered.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return filtered;
  }

  @override
  Future<ActivityEvent?> getCurrentActiveActivity(
      String shiftSessionId) async {
    final events = await getEventsByShift(shiftSessionId);
    for (final event in events.reversed) {
      if (event.eventName == 'ACTIVITY_ENDED' ||
          event.eventName == 'SHIFT_ENDED') {
        return null;
      }
      if (event.eventName == 'ACTIVITY_STARTED') {
        return event;
      }
    }
    return null;
  }

  @override
  Future<void> clearEvents() async {
    _events.clear();
  }
}
