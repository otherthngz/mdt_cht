import 'event_models.dart';

class ActivitySession {
  ActivitySession({
    required this.startedAtUtc,
    required this.category,
    required this.state,
    this.reasonCode,
    this.notes,
  });

  final DateTime startedAtUtc;
  final ActivityCategory category;
  final ActivityState state;
  final String? reasonCode;
  final String? notes;
}

class ActivityStopResult {
  ActivityStopResult({
    required this.startedAtUtc,
    required this.stoppedAtUtc,
    required this.elapsed,
    required this.category,
    required this.state,
    this.reasonCode,
    this.notes,
  });

  final DateTime startedAtUtc;
  final DateTime stoppedAtUtc;
  final Duration elapsed;
  final ActivityCategory category;
  final ActivityState state;
  final String? reasonCode;
  final String? notes;
}

class ActivityTimerLogic {
  ActivitySession? _active;

  ActivitySession? get activeSession => _active;

  void start({
    required DateTime startedAtUtc,
    required ActivityCategory category,
    required ActivityState state,
    String? reasonCode,
    String? notes,
  }) {
    if (_active != null) {
      throw StateError('An activity is already running.');
    }
    _active = ActivitySession(
      startedAtUtc: startedAtUtc,
      category: category,
      state: state,
      reasonCode: reasonCode,
      notes: notes,
    );
  }

  ActivityStopResult stop({required DateTime stoppedAtUtc}) {
    final active = _active;
    if (active == null) {
      throw StateError('No active activity to stop.');
    }
    if (stoppedAtUtc.isBefore(active.startedAtUtc)) {
      throw StateError('Stop time cannot be before start time.');
    }

    _active = null;
    return ActivityStopResult(
      startedAtUtc: active.startedAtUtc,
      stoppedAtUtc: stoppedAtUtc,
      elapsed: stoppedAtUtc.difference(active.startedAtUtc),
      category: active.category,
      state: active.state,
      reasonCode: active.reasonCode,
      notes: active.notes,
    );
  }
}
