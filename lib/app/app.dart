import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/activity/active_timer_screen.dart';
import '../features/activity/activity_log_screen.dart';
import '../features/activity/activity_timer_screen.dart';
import '../features/activity/status_saat_ini_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/dispatch/dispatch_inbox_screen.dart';
import '../features/hm/end_shift_screen.dart';
import '../features/hm/hm_start_screen.dart';
import '../features/hm/ringkasan_pekerjaan_screen.dart';
import '../features/p2h/p2h_screen.dart';
import '../features/sync/sync_status_screen.dart';
import '../features/unit/select_unit_screen.dart';
import 'providers.dart';
import 'routes.dart';

class MdtApp extends ConsumerWidget {
  const MdtApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncCoordinatorProvider);

    return MaterialApp(
      title: 'MDT POC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      routes: {
        // Primary flow
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.hmMulai: (_) => const CnUnitFormScreen(mode: CnUnitFormMode.hmMulai),
        AppRoutes.p2h: (_) => const P2HScreen(),
        AppRoutes.statusSaatIni: (_) => const StatusSaatIniScreen(),
        AppRoutes.activityLog: (_) => const ActivityLogScreen(),
        AppRoutes.activeTimer: (_) => const ActiveTimerScreen(),
        AppRoutes.hmAkhir: (_) => const CnUnitFormScreen(mode: CnUnitFormMode.hmAkhir),
        AppRoutes.ringkasan: (_) => const RingkasanPekerjaanScreen(),
        // BUG-9 fix: previously unreachable screens now registered under their
        // own unique route strings (dispatch, syncStatus are not aliases).
        AppRoutes.dispatch: (_) => const DispatchInboxScreen(),
        AppRoutes.syncStatus: (_) => const SyncStatusScreen(),
        // Additional screens accessible via push (not main flow)
        '/select-unit': (_) => const SelectUnitScreen(),
        '/activity-timer': (_) => const ActivityTimerScreen(),
        '/end-shift': (_) => const EndShiftScreen(),
      },
    );
  }
}
