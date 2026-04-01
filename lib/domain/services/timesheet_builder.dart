import 'package:ptba_mdt/domain/models/activity_event.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/models/timesheet_row.dart';

/// TimesheetBuilder — per 06_ARCHITECTURE.md §8.
///
/// Derives [TimesheetRow] list from raw [ActivityEvent] list
/// and the parent [ShiftSession].
///
/// Algorithm:
///   1. Filter to ACTIVITY_STARTED / ACTIVITY_ENDED only
///   2. Walk sequentially, pair start→end
///   3. Compute durationSeconds
///   4. Accumulate loadingCount / haulingCount
///   5. Derive HM values (only when hmEnd is available)
///   6. Mark last unpaired row as isActive = true
class TimesheetBuilder {
  /// Build timesheet rows from [events] belonging to [session].
  ///
  /// Events should already be sorted by occurredAt (ascending).
  List<TimesheetRow> build(
    List<ActivityEvent> events,
    ShiftSession session,
  ) {
    final rows = <_MutableRow>[];
    int runningLoadingCount = 0;
    int runningHaulingCount = 0;

    for (final event in events) {
      if (event.eventName == 'ACTIVITY_STARTED') {
        // Increment cumulative counts
        if (event.activitySubtype == 'loading') {
          runningLoadingCount++;
        } else if (event.activitySubtype == 'hauling') {
          runningHaulingCount++;
        }

        rows.add(_MutableRow(
          shiftSessionId: session.shiftSessionId,
          category: event.activityCategory ?? '',
          activity: event.activitySubtype ?? '',
          startTime: event.occurredAt,
          loaderCode: event.loaderCode,
          haulingCode: event.haulingCode,
          loadingCount: runningLoadingCount,
          haulingCount: runningHaulingCount,
        ));
      } else if (event.eventName == 'ACTIVITY_ENDED') {
        // Find the last open row (endTime == null)
        final openRow = _findLastOpenRow(rows);
        if (openRow != null) {
          openRow.endTime = event.occurredAt;
          openRow.durationSeconds = _computeDuration(
            openRow.startTime,
            event.occurredAt,
          );
        }
      }
      // Skip SHIFT_STARTED and SHIFT_ENDED
    }

    // Mark last row as active if it has no endTime
    if (rows.isNotEmpty && rows.last.endTime == null) {
      rows.last.isActive = true;
    }

    // Derive HM values
    _deriveHmValues(rows, session);

    // Convert to immutable TimesheetRow list
    return rows.asMap().entries.map((entry) {
      final i = entry.key;
      final r = entry.value;
      return TimesheetRow(
        rowId: '${session.shiftSessionId}_$i',
        shiftSessionId: r.shiftSessionId,
        category: r.category,
        activity: r.activity,
        startTime: r.startTime,
        endTime: r.endTime,
        durationSeconds: r.durationSeconds,
        hmStartDerived: r.hmStartDerived,
        hmEndDerived: r.hmEndDerived,
        deltaHmDerived: r.deltaHmDerived,
        loaderCode: r.loaderCode,
        haulingCode: r.haulingCode,
        loadingCount: r.loadingCount,
        haulingCount: r.haulingCount,
        isActive: r.isActive,
      );
    }).toList();
  }

  /// Find the last row that has no endTime.
  _MutableRow? _findLastOpenRow(List<_MutableRow> rows) {
    for (int i = rows.length - 1; i >= 0; i--) {
      if (rows[i].endTime == null) return rows[i];
    }
    return null;
  }

  /// Compute duration in seconds between two ISO datetime strings.
  int _computeDuration(String start, String end) {
    final s = DateTime.parse(start);
    final e = DateTime.parse(end);
    final diff = e.difference(s).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  /// Derive HM values for all rows.
  ///
  /// HM derivation only works when hmEnd is available.
  /// Formula:
  ///   totalShiftSeconds = sum of all row durations
  ///   hmRange = hmEnd - hmStart
  ///   For each row:
  ///     cumulativeAtStart = sum of preceding rows' durations
  ///     cumulativeAtEnd   = cumulativeAtStart + this row's duration
  ///     hmStartDerived = hmStart + (cumulativeAtStart / totalShiftSeconds) * hmRange
  ///     hmEndDerived   = hmStart + (cumulativeAtEnd / totalShiftSeconds) * hmRange
  ///     deltaHmDerived = hmEndDerived - hmStartDerived
  void _deriveHmValues(List<_MutableRow> rows, ShiftSession session) {
    if (session.hmEnd == null) return; // Can't derive without hmEnd

    final hmStart = session.hmStart;
    final hmEnd = session.hmEnd!;
    final hmRange = hmEnd - hmStart;

    // Compute total shift seconds (active row uses now - startTime)
    int totalShiftSeconds = 0;
    for (final row in rows) {
      if (row.durationSeconds != null) {
        totalShiftSeconds += row.durationSeconds!;
      } else if (row.isActive) {
        // Active row: use live duration
        final start = DateTime.parse(row.startTime);
        totalShiftSeconds += DateTime.now().difference(start).inSeconds;
      }
    }

    if (totalShiftSeconds <= 0) return;

    int cumulativeSeconds = 0;
    for (final row in rows) {
      final rowDuration = row.durationSeconds ??
          (row.isActive
              ? DateTime.now()
                  .difference(DateTime.parse(row.startTime))
                  .inSeconds
              : 0);

      final ratioStart = cumulativeSeconds / totalShiftSeconds;
      final ratioEnd = (cumulativeSeconds + rowDuration) / totalShiftSeconds;

      row.hmStartDerived = hmStart + ratioStart * hmRange;
      row.hmEndDerived = hmStart + ratioEnd * hmRange;
      row.deltaHmDerived = row.hmEndDerived! - row.hmStartDerived!;

      cumulativeSeconds += rowDuration;
    }
  }
}

/// Internal mutable row used during building.
class _MutableRow {
  final String shiftSessionId;
  final String category;
  final String activity;
  final String startTime;
  String? endTime;
  int? durationSeconds;
  double? hmStartDerived;
  double? hmEndDerived;
  double? deltaHmDerived;
  final String? loaderCode;
  final String? haulingCode;
  final int loadingCount;
  final int haulingCount;
  bool isActive = false;

  _MutableRow({
    required this.shiftSessionId,
    required this.category,
    required this.activity,
    required this.startTime,
    this.loaderCode,
    this.haulingCode,
    this.loadingCount = 0,
    this.haulingCount = 0,
  });
}
