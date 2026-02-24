import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/session_state.dart';
import '../../core/events/event_models.dart';

class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  Map<SyncStatus, int> _counts = {
    SyncStatus.pending: 0,
    SyncStatus.sent: 0,
    SyncStatus.failed: 0,
  };
  List<EventEnvelope> _failedConflicts = [];
  bool _loading = true;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = ref.read(mdtServiceProvider);
    final counts = await service.getSyncCounts();
    final failedConflicts = await service.listFailedConflicts();

    if (!mounted) {
      return;
    }
    setState(() {
      _counts = counts;
      _failedConflicts = failedConflicts;
      _loading = false;
    });
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    try {
      final service = ref.read(mdtServiceProvider);
      final result = await service.syncNow();
      await _load();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Processed ${result.processed}, sent ${result.sent}, failed ${result.failed}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  Future<void> _createCorrection(EventEnvelope failedEvent) async {
    final correctionController = TextEditingController();
    final decision = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create correction event'),
        content: TextField(
          controller: correctionController,
          decoration: const InputDecoration(
            labelText: 'Correction reason/details',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (decision != true || correctionController.text.trim().isEmpty) {
      return;
    }

    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) {
      return;
    }

    final service = ref.read(mdtServiceProvider);
    await service.createCorrectionEvent(
      operatorId: session.operatorId!,
      unitId: session.unitId!,
      failedEvent: failedEvent,
      correctionPayload: {
        'note': correctionController.text.trim(),
      },
    );

    if (!mounted) {
      return;
    }
    await _load();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Correction event created and queued.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Status')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pending: ${_counts[SyncStatus.pending] ?? 0}'),
                    Text('Sent: ${_counts[SyncStatus.sent] ?? 0}'),
                    Text('Failed: ${_counts[SyncStatus.failed] ?? 0}'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _syncing ? null : _syncNow,
                      icon: const Icon(Icons.sync),
                      label: Text(_syncing ? 'Syncing...' : 'Sync now'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Failed conflicts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_failedConflicts.isEmpty)
              const Text('No assignment conflict failures.'),
            ..._failedConflicts.map(
              (event) => Card(
                child: ListTile(
                  // UI-3 fix: show wire value (e.g. ASSIGNMENT_DECISION_SUBMITTED)
                  // and only the last 8 chars of the UUID — readable for operators
                  title: Text(
                    '${event.eventType.wireValue} …${event.eventId.substring(event.eventId.length - 8)}',
                  ),
                  subtitle: Text(
                    '${event.lastErrorCode ?? 'UNKNOWN'}: ${event.lastErrorMessage ?? '-'}',
                  ),
                  trailing: TextButton(
                    onPressed: () => _createCorrection(event),
                    child: const Text('Create correction'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
