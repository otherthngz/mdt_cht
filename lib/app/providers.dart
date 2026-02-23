import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/app_database.dart';
import '../core/db/assignment_repository.dart';
import '../core/db/event_repository.dart';
import '../core/db/reason_code_repository.dart';
import '../core/db/shift_session_repository.dart';
import '../core/events/event_factory.dart';
import '../core/network/event_api_client.dart';
import '../core/network/mock_event_api_client.dart';
import '../core/sync/sync_coordinator.dart';
import '../core/sync/sync_service.dart';
import 'mdt_service.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Override appDatabaseProvider in main().'),
);

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => EventRepository(ref.watch(appDatabaseProvider)),
);

final assignmentRepositoryProvider = Provider<AssignmentRepository>(
  (ref) => AssignmentRepository(ref.watch(appDatabaseProvider)),
);

final reasonCodeRepositoryProvider = Provider<ReasonCodeRepository>(
  (ref) => ReasonCodeRepository(ref.watch(appDatabaseProvider)),
);

final shiftSessionRepositoryProvider = Provider<ShiftSessionRepository>(
  (ref) => ShiftSessionRepository(ref.watch(appDatabaseProvider)),
);

final eventFactoryProvider = Provider<EventFactory>(
  (ref) => EventFactory(deviceId: 'POC-DEVICE-001'),
);

final apiClientProvider = Provider<EventApiClient>(
  (ref) => MockEventApiClient(),
);

final backoffPolicyProvider = Provider<BackoffPolicy>(
  (ref) => BackoffPolicy(),
);

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    queueStore: ref.watch(eventRepositoryProvider),
    apiClient: ref.watch(apiClientProvider),
    backoffPolicy: ref.watch(backoffPolicyProvider),
  ),
);

final syncCoordinatorProvider = Provider<SyncCoordinator>(
  (ref) {
    final coordinator = SyncCoordinator(syncService: ref.watch(syncServiceProvider));
    coordinator.start();
    ref.onDispose(coordinator.dispose);
    return coordinator;
  },
);

final mdtServiceProvider = Provider<MdtService>(
  (ref) => MdtService(
    eventRepository: ref.watch(eventRepositoryProvider),
    assignmentRepository: ref.watch(assignmentRepositoryProvider),
    reasonCodeRepository: ref.watch(reasonCodeRepositoryProvider),
    shiftSessionRepository: ref.watch(shiftSessionRepositoryProvider),
    eventFactory: ref.watch(eventFactoryProvider),
    eventApiClient: ref.watch(apiClientProvider),
    syncService: ref.watch(syncServiceProvider),
  ),
);
