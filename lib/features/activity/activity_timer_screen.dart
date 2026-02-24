import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/mdt_service.dart';
import '../../app/providers.dart';
import '../../app/session_state.dart';
import '../../core/events/event_models.dart';

class ActivityTimerScreen extends ConsumerStatefulWidget {
  const ActivityTimerScreen({super.key});

  @override
  ConsumerState<ActivityTimerScreen> createState() => _ActivityTimerScreenState();
}

class _ActivityTimerScreenState extends ConsumerState<ActivityTimerScreen> {
  ActivityCategory _category = ActivityCategory.production;
  ActivityState _state = ActivityState.running;
  String? _reasonCode;
  final _notesController = TextEditingController();

  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  Timer? _ticker;
  bool _busy = false;

  @override
  void dispose() {
    _ticker?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _startedAt == null) {
        return;
      }
      setState(() {
        _elapsed = DateTime.now().toUtc().difference(_startedAt!);
      });
    });
  }

  Future<void> _start(MdtService service) async {
    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) {
      return;
    }

    setState(() => _busy = true);
    try {
      await service.startActivity(
        operatorId: session.operatorId!,
        unitId: session.unitId!,
        category: _category,
        state: _state,
        reasonCode: _reasonCode,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text,
      );
      setState(() {
        _startedAt = DateTime.now().toUtc();
        _elapsed = Duration.zero;
      });
      _startTicker();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _stop(MdtService service) async {
    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) {
      return;
    }

    setState(() => _busy = true);
    try {
      final elapsed = await service.stopActivity(
        operatorId: session.operatorId!,
        unitId: session.unitId!,
      );
      _ticker?.cancel();
      setState(() {
        _startedAt = null;
        _elapsed = elapsed;
      });
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Activity stopped. Elapsed: ${elapsed.inMinutes} min')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  String _format(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(mdtServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Timer')),
      body: FutureBuilder<List<ReasonCode>>(
        future: service.listReasonCodes(),
        builder: (context, snapshot) {
          final reasons = snapshot.data ?? const <ReasonCode>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Elapsed', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        _format(_elapsed),
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ActivityCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ActivityCategory.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                // UI-2 fix: lock when timer is running
                onChanged: _startedAt != null
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _category = value);
                        }
                      },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ActivityState>(
                initialValue: _state,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
                items: ActivityState.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                // UI-2 fix: lock when timer is running
                onChanged: _startedAt != null
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _state = value);
                        }
                      },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _reasonCode,
                decoration: const InputDecoration(
                  labelText: 'Reason code (optional)',
                  border: OutlineInputBorder(),
                ),
                items: reasons
                    .map(
                      (reason) => DropdownMenuItem(
                        value: reason.code,
                        child: Text('${reason.code} - ${reason.label}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _reasonCode = value),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy || _startedAt != null
                          ? null
                          : () => _start(service),
                      child: const Text('Start Activity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy || _startedAt == null
                          ? null
                          : () => _stop(service),
                      child: const Text('Stop Activity'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
