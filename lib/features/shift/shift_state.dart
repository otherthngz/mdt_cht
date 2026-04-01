import 'package:ptba_mdt/domain/models/shift_session.dart';

/// ShiftState — per 06_ARCHITECTURE.md §6.
class ShiftState {
  final ShiftSession? shiftSession;
  final bool isActive;

  /// True when shift has been finalized via End Shift.
  final bool isEnded;

  /// Current activity info (derived from latest ACTIVITY_STARTED event).
  final String? currentCategory;
  final String? currentSubtype;
  final String? currentActivityStartedAt;
  final String? currentLoaderCode;
  final String? currentHaulingCode;

  /// Loading indicator.
  final bool isLoading;

  /// Error message.
  final String? error;

  const ShiftState({
    this.shiftSession,
    this.isActive = false,
    this.isEnded = false,
    this.currentCategory,
    this.currentSubtype,
    this.currentActivityStartedAt,
    this.currentLoaderCode,
    this.currentHaulingCode,
    this.isLoading = false,
    this.error,
  });

  /// Initial state — no shift started.
  const ShiftState.initial()
      : shiftSession = null,
        isActive = false,
        isEnded = false,
        currentCategory = null,
        currentSubtype = null,
        currentActivityStartedAt = null,
        currentLoaderCode = null,
        currentHaulingCode = null,
        isLoading = false,
        error = null;

  ShiftState copyWith({
    ShiftSession? shiftSession,
    bool? isActive,
    bool? isEnded,
    String? currentCategory,
    String? currentSubtype,
    String? currentActivityStartedAt,
    String? currentLoaderCode,
    String? currentHaulingCode,
    bool? isLoading,
    String? error,
  }) {
    return ShiftState(
      shiftSession: shiftSession ?? this.shiftSession,
      isActive: isActive ?? this.isActive,
      isEnded: isEnded ?? this.isEnded,
      currentCategory: currentCategory ?? this.currentCategory,
      currentSubtype: currentSubtype ?? this.currentSubtype,
      currentActivityStartedAt:
          currentActivityStartedAt ?? this.currentActivityStartedAt,
      currentLoaderCode: currentLoaderCode ?? this.currentLoaderCode,
      currentHaulingCode: currentHaulingCode ?? this.currentHaulingCode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
