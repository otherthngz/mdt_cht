import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';

class ActiveTimerScreen extends ConsumerStatefulWidget {
  const ActiveTimerScreen({super.key});

  @override
  ConsumerState<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends ConsumerState<ActiveTimerScreen> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  bool _stopping = false;

  @override
  void initState() {
    super.initState();
    _refreshElapsed();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _refreshElapsed());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _refreshElapsed() {
    final start = ref.read(sessionProvider).activityStartedAtUtc;
    if (start == null) {
      return;
    }
    if (mounted) {
      setState(() {
        _elapsed = DateTime.now().toUtc().difference(start);
      });
    }
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _stop() async {
    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) {
      return;
    }

    setState(() => _stopping = true);
    try {
      await ref.read(mdtServiceProvider).stopActivity(
            operatorId: session.operatorId!,
            unitId: session.unitId!,
          );
      ref.read(sessionProvider.notifier).clearActivity();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.statusSaatIni,
        (route) => route.settings.name == AppRoutes.statusSaatIni,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _stopping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final activity = args?['activity'] as String? ?? ref.watch(sessionProvider).activeActivityLabel ?? 'Activity';

    return Scaffold(
      appBar: AppBar(title: Text(activity)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Timer', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              _fmt(_elapsed),
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _stopping ? null : _stop,
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(_stopping ? 'Stopping...' : 'Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
