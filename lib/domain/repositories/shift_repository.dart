import 'package:ptba_mdt/domain/models/shift_session.dart';

/// Repository interface for ShiftSession persistence.
/// Per 05_DATA_MODEL.md §12 and 06_ARCHITECTURE.md §4.4.
abstract class ShiftRepository {
  /// Save a new shift session.
  Future<void> saveShiftSession(ShiftSession session);

  /// Get the currently active shift session, or null if none.
  Future<ShiftSession?> getActiveShiftSession();

  /// Update an existing shift session (e.g., set hmEnd, endedAt, status).
  Future<void> updateShiftSession(ShiftSession session);

  /// Get the latest shift session regardless of status (active or ended).
  /// Used for state restoration on app restart.
  Future<ShiftSession?> getLatestShiftSession();

  /// Clear stored shift session data.
  Future<void> clearShiftSession();
}
