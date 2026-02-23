import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';
import '../../core/events/event_models.dart';

class StatusSaatIniScreen extends ConsumerStatefulWidget {
  const StatusSaatIniScreen({super.key});

  @override
  ConsumerState<StatusSaatIniScreen> createState() => _StatusSaatIniScreenState();
}

class _StatusSaatIniScreenState extends ConsumerState<StatusSaatIniScreen> {
  Timer? _clock;
  String _timerText = '00:00:00';

  @override
  void initState() {
    super.initState();
    _recomputeTimer();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _recomputeTimer());
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  void _recomputeTimer() {
    final session = ref.read(sessionProvider);
    final start = session.shiftStartedAtUtc;
    if (start == null) {
      if (_timerText != '00:00:00' && mounted) {
        setState(() => _timerText = '00:00:00');
      }
      return;
    }

    final d = DateTime.now().toUtc().difference(start);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final next = '$h:$m:$s';
    if (mounted && next != _timerText) {
      setState(() => _timerText = next);
    }
  }

  Future<void> _openActivityLog(ActivityState state) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.activityLog,
      arguments: {
        'state': state.name,
      },
    );
    _recomputeTimer();
  }

  Future<void> _endShift() async {
    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) {
      return;
    }

    final service = ref.read(mdtServiceProvider);
    await service.requestEndShift(
      operatorId: session.operatorId!,
      unitId: session.unitId!,
    );

    final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Apakah anda yakin ingin mengakhiri pekerjaan?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Kembali'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Ya, Akhiri'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) {
      return;
    }

    await service.confirmEndShift(
      operatorId: session.operatorId!,
      unitId: session.unitId!,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamed(AppRoutes.hmAkhir);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text('Operator ${session.operatorId ?? '-'}'),
              const SizedBox(width: 12),
              Text('Unit ${session.unitId ?? 'H515'}'),
              const SizedBox(width: 12),
              const Text('Status Online', style: TextStyle(color: Colors.green)),
              const SizedBox(width: 12),
              Text('Timer $_timerText'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _endShift,
            child: const Text('End Shift', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Status Saat Ini',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              color: const Color(0xFFF2F4F7),
              child: Center(
                child: Text(
                  session.activeActivityLabel == null
                      ? 'Belum Ada Aktivitas'
                      : session.activeActivityLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0EAE7A),
                      side: const BorderSide(color: Color(0xFF0EAE7A), width: 2),
                      minimumSize: const Size(0, 64),
                    ),
                    onPressed: () => _openActivityLog(ActivityState.running),
                    child: const Text('ACTIVITY'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB88700),
                      side: const BorderSide(color: Color(0xFFB88700), width: 2),
                      minimumSize: const Size(0, 64),
                    ),
                    onPressed: () => _openActivityLog(ActivityState.standbyDelay),
                    child: const Text('STANDBY'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD92D20),
                      side: const BorderSide(color: Color(0xFFD92D20), width: 2),
                      minimumSize: const Size(0, 64),
                    ),
                    onPressed: () => _openActivityLog(ActivityState.breakdown),
                    child: const Text('BREAKDOWN'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
