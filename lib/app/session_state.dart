import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/events/event_models.dart';

class AppSessionState {
  const AppSessionState({
    this.operatorId,
    this.unitId,
    this.shiftSessionId,
    this.shiftStartedAtUtc,
    this.hmStart,
    this.hmEnd,
    this.activeStatus,
    this.activeActivityLabel,
    this.activityStartedAtUtc,
  });

  final String? operatorId;
  final String? unitId;
  final String? shiftSessionId;
  final DateTime? shiftStartedAtUtc;
  final double? hmStart;
  final double? hmEnd;
  final ActivityState? activeStatus;
  final String? activeActivityLabel;
  final DateTime? activityStartedAtUtc;

  bool get isLoggedIn => operatorId != null && operatorId!.isNotEmpty;
  bool get hasUnit => unitId != null && unitId!.isNotEmpty;
  bool get hasShift => shiftSessionId != null && shiftSessionId!.isNotEmpty;

  AppSessionState copyWith({
    String? operatorId,
    String? unitId,
    String? shiftSessionId,
    DateTime? shiftStartedAtUtc,
    double? hmStart,
    double? hmEnd,
    ActivityState? activeStatus,
    String? activeActivityLabel,
    DateTime? activityStartedAtUtc,
    bool clearShift = false,
    bool clearActivity = false,
    bool clearAll = false,
  }) {
    if (clearAll) {
      return const AppSessionState();
    }

    return AppSessionState(
      operatorId: operatorId ?? this.operatorId,
      unitId: unitId ?? this.unitId,
      shiftSessionId: clearShift ? null : shiftSessionId ?? this.shiftSessionId,
      shiftStartedAtUtc:
          clearShift ? null : shiftStartedAtUtc ?? this.shiftStartedAtUtc,
      hmStart: clearShift ? null : hmStart ?? this.hmStart,
      hmEnd: clearShift ? null : hmEnd ?? this.hmEnd,
      activeStatus: clearActivity ? null : activeStatus ?? this.activeStatus,
      activeActivityLabel:
          clearActivity ? null : activeActivityLabel ?? this.activeActivityLabel,
      activityStartedAtUtc:
          clearActivity ? null : activityStartedAtUtc ?? this.activityStartedAtUtc,
    );
  }
}

class SessionController extends StateNotifier<AppSessionState> {
  SessionController() : super(const AppSessionState());

  void setOperator(String operatorId) {
    state = state.copyWith(operatorId: operatorId);
  }

  void startShift({
    required String unitId,
    required String sessionId,
    required double hmStart,
    required DateTime shiftStartedAtUtc,
  }) {
    state = state.copyWith(
      unitId: unitId,
      shiftSessionId: sessionId,
      shiftStartedAtUtc: shiftStartedAtUtc,
      hmStart: hmStart,
      hmEnd: null,
    );
  }

  // Backward-compatible helpers for legacy screens.
  void setUnit(String unitId) {
    state = state.copyWith(unitId: unitId);
  }

  void setShift({required String sessionId, required double hmStart}) {
    startShift(
      unitId: state.unitId ?? 'H515',
      sessionId: sessionId,
      hmStart: hmStart,
      shiftStartedAtUtc: DateTime.now().toUtc(),
    );
  }

  void setHmEnd(double hmEnd) {
    state = state.copyWith(hmEnd: hmEnd);
  }

  void setActiveActivity({
    required ActivityState stateValue,
    required String activityLabel,
    required DateTime startedAtUtc,
  }) {
    state = state.copyWith(
      activeStatus: stateValue,
      activeActivityLabel: activityLabel,
      activityStartedAtUtc: startedAtUtc,
    );
  }

  void clearActivity() {
    state = state.copyWith(clearActivity: true);
  }

  void clearShift() {
    state = state.copyWith(clearShift: true, clearActivity: true);
  }

  void resetAll() {
    state = state.copyWith(clearAll: true);
  }
}

final sessionProvider =
    StateNotifierProvider<SessionController, AppSessionState>(
  (ref) => SessionController(),
);
