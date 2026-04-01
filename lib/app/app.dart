import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ptba_mdt/app/routes.dart';
import 'package:ptba_mdt/app/theme/theme.dart';
import 'package:ptba_mdt/features/shift/shift_controller.dart';

/// Root MaterialApp widget.
/// Wraps with _AppRestorer to handle state restoration on app start.
class MdtApp extends StatelessWidget {
  const MdtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MDT - Mobile Dispatch Terminal',
      debugShowCheckedModeBanner: false,
      theme: MdtTheme.lightTheme,
      home: const _AppRestorer(),
      routes: {
        AppRoutes.startShiftStep2: (context) =>
            AppRoutes.routes[AppRoutes.startShiftStep2]!(context),
        AppRoutes.mainActivity: (context) =>
            AppRoutes.routes[AppRoutes.mainActivity]!(context),
        AppRoutes.timesheet: (context) =>
            AppRoutes.routes[AppRoutes.timesheet]!(context),
        AppRoutes.shiftEnded: (context) =>
            AppRoutes.routes[AppRoutes.shiftEnded]!(context),
      },
    );
  }
}

/// Single restore entry point for the app.
///
/// On startup:
///   1. Call restoreShift() once
///   2. If active shift exists → navigate to MainActivityPage
///   3. Otherwise → show StartShiftPage
///
/// Per adjustment #1: restore happens here only, not in MainActivityPage.
class _AppRestorer extends ConsumerStatefulWidget {
  const _AppRestorer();

  @override
  ConsumerState<_AppRestorer> createState() => _AppRestorerState();
}

class _AppRestorerState extends ConsumerState<_AppRestorer> {
  bool _isRestoring = true;

  @override
  void initState() {
    super.initState();
    // Defer restore to after the first frame to avoid modifying providers
    // during the widget tree build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  Future<void> _restore() async {
    await ref.read(shiftControllerProvider.notifier).restoreShift();
    if (!mounted) return;

    final shiftState = ref.read(shiftControllerProvider);

    setState(() => _isRestoring = false);

    if (shiftState.isActive && shiftState.shiftSession != null) {
      // Active shift found → go to MainActivityPage
      Navigator.pushReplacementNamed(context, AppRoutes.mainActivity);
    } else if (shiftState.isEnded && shiftState.shiftSession != null) {
      // Ended shift found → go to ShiftEndedPage
      Navigator.pushReplacementNamed(context, AppRoutes.shiftEnded);
    }
    // Otherwise: stay on StartShiftPage (rendered below)
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoring) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Memuat data...',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF616161),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // No active shift → show StartShiftPage
    return AppRoutes.routes[AppRoutes.startShift]!(context);
  }
}
