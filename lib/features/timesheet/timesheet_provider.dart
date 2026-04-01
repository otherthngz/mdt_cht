import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptba_mdt/domain/models/timesheet_row.dart';
import 'package:ptba_mdt/domain/services/timesheet_builder.dart';
import 'package:ptba_mdt/features/shift/shift_controller.dart';

/// Provider that builds timesheet rows from stored events.
///
/// Returns a [Future] of [List] of [TimesheetRow] — derived on every call,
/// never persisted.
final timesheetProvider =
    FutureProvider.autoDispose<List<TimesheetRow>>((ref) async {
  final shiftState = ref.watch(shiftControllerProvider);
  final session = shiftState.shiftSession;
  if (session == null) return [];

  final eventRepo = ref.read(activityEventRepositoryProvider);
  final events = await eventRepo.getEventsByShift(session.shiftSessionId);

  final builder = TimesheetBuilder();
  return builder.build(events, session);
});
