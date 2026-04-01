import 'package:ptba_mdt/domain/models/activity_event.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/repositories/activity_event_repository.dart';
import 'package:ptba_mdt/domain/repositories/shift_repository.dart';
import 'package:ptba_mdt/domain/services/operator_activity_api.dart';

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
    final filtered = _events
        .where((e) => e.shiftSessionId == shiftSessionId)
        .toList();
    filtered.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return filtered;
  }

  @override
  Future<ActivityEvent?> getCurrentActiveActivity(String shiftSessionId) async {
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

class LoggedOperatorApiCall {
  final String action;
  final Map<String, Object?> payload;

  const LoggedOperatorApiCall({required this.action, required this.payload});
}

/// In-memory mock of [OperatorActivityApi] for testing.
class MockOperatorActivityApi implements OperatorActivityApi {
  final List<LoggedOperatorApiCall> _calls = [];

  List<LoggedOperatorApiCall> get calls => List.unmodifiable(_calls);

  @override
  Future<void> postEndShift({
    required String shiftSessionId,
    required double hmEnd,
  }) async {
    _calls.add(
      LoggedOperatorApiCall(
        action: 'endShift',
        payload: {'shiftSessionId': shiftSessionId, 'hmEnd': hmEnd},
      ),
    );
  }

  @override
  Future<void> postInteraction({
    required String action,
    String? shiftSessionId,
    String? unitId,
    String? operatorId,
    Map<String, Object?> metadata = const {},
  }) async {
    _calls.add(
      LoggedOperatorApiCall(
        action: action,
        payload: {
          'shiftSessionId': shiftSessionId,
          'unitId': unitId,
          'operatorId': operatorId,
          'metadata': metadata,
        },
      ),
    );
  }

  @override
  Future<void> postStartShift({
    required String unitId,
    required String operatorId,
    required double hmStart,
  }) async {
    _calls.add(
      LoggedOperatorApiCall(
        action: 'startShift',
        payload: {
          'unitId': unitId,
          'operatorId': operatorId,
          'hmStart': hmStart,
        },
      ),
    );
  }

  @override
  Future<void> postSwitchActivity({
    required String shiftSessionId,
    required String nextActivityCategory,
    required String nextActivitySubtype,
    String? loaderCode,
    String? haulingCode,
  }) async {
    _calls.add(
      LoggedOperatorApiCall(
        action: 'switchActivity',
        payload: {
          'shiftSessionId': shiftSessionId,
          'nextActivityCategory': nextActivityCategory,
          'nextActivitySubtype': nextActivitySubtype,
          'loaderCode': loaderCode,
          'haulingCode': haulingCode,
        },
      ),
    );
  }
}
