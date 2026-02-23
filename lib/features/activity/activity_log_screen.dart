import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';
import '../../core/events/event_models.dart';

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
                  for (final activity in ['Activity 1', 'Activity 2', 'Activity 3', 'Activity 4'])
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
                            await service.selectActivityOption(
                              operatorId: session.operatorId!,
                              unitId: session.unitId!,
                              state: state,
                              activityName: activity,
                            );

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
