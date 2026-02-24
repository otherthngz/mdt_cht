import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';
import '../../core/events/event_models.dart';

/// Activities shown per state, matching real MDT categories.
const _activitiesByState = <ActivityState, List<String>>{
  ActivityState.running: [
    'Loading',
    'Hauling',
    'Dumping',
    'Spotting',
  ],
  ActivityState.standbyDelay: [
    'Fuel',
    'Operator Break',
    'Traffic Jam',
    'Waiting Instruction',
  ],
  ActivityState.breakdown: [
    'Engine Trouble',
    'Tire Damage',
    'Electrical Fault',
    'Hydraulic Issue',
  ],
};

class ActivityLogScreen extends ConsumerWidget {
  const ActivityLogScreen({super.key});

  ActivityState _readState(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final raw = args?['state'] as String?;
    return ActivityState.values.firstWhere(
      (item) => item.name == raw,
      orElse: () => ActivityState.running,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = _readState(context);
    // LOGIC-3 fix: state-specific activity lists
    final activities = _activitiesByState[state] ?? _activitiesByState[ActivityState.running]!;

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log')),
      body: Center(
        child: Card(
          child: SizedBox(
            width: 380,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Activity Log',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final activity in activities)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: () async {
                            final session = ref.read(sessionProvider);
                            if (session.operatorId == null || session.unitId == null) {
                              return;
                            }

                            final service = ref.read(mdtServiceProvider);
                            // BUG-2 fix: only call startSelectedActivity (which combines
                            // ACTIVITY_SELECTED + ACTIVITY_STARTED into one action).
                            // Removed the separate selectActivityOption call that was
                            // causing a double ACTIVITY_STARTED event.
                            final startedAt = await service.startSelectedActivity(
                              operatorId: session.operatorId!,
                              unitId: session.unitId!,
                              state: state,
                              activityName: activity,
                            );

                            ref.read(sessionProvider.notifier).setActiveActivity(
                                  stateValue: state,
                                  activityLabel: activity,
                                  startedAtUtc: startedAt,
                                );

                            if (!context.mounted) {
                              return;
                            }
                            Navigator.of(context).pushReplacementNamed(
                              AppRoutes.activeTimer,
                              arguments: {
                                'activity': activity,
                                'state': state.name,
                              },
                            );
                          },
                          child: Text(activity),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
