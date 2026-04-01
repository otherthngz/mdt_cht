import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptba_mdt/domain/models/shift_summary.dart';
import 'package:ptba_mdt/domain/services/summary_calculator.dart';
import 'package:ptba_mdt/features/shift/shift_controller.dart';

/// Provider that builds shift summary from stored events.
///
/// Returns a [Future] of [ShiftSummary] — derived on every call,
/// never persisted.
final summaryProvider =
    FutureProvider.autoDispose<ShiftSummary?>((ref) async {
  final shiftState = ref.watch(shiftControllerProvider);
  final session = shiftState.shiftSession;
  if (session == null) return null;

  final eventRepo = ref.read(activityEventRepositoryProvider);
  final events = await eventRepo.getEventsByShift(session.shiftSessionId);

  final calculator = SummaryCalculator();
  return calculator.calculate(events, session);
});
