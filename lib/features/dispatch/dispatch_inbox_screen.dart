import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/mdt_service.dart';
import '../../app/providers.dart';
import '../../app/session_state.dart';
import '../../core/events/event_models.dart';

class DispatchInboxScreen extends ConsumerStatefulWidget {
  const DispatchInboxScreen({super.key});

  @override
  ConsumerState<DispatchInboxScreen> createState() => _DispatchInboxScreenState();
}

class _DispatchInboxScreenState extends ConsumerState<DispatchInboxScreen> {
  bool _loading = false;
  List<Assignment> _assignments = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final service = ref.read(mdtServiceProvider);
    final data = await service.listAssignments();
    if (mounted) {
      setState(() => _assignments = data);
    }
  }

  Future<void> _refreshSystemAssignments() async {
    final session = ref.read(sessionProvider);
    final operatorId = session.operatorId;
    final unitId = session.unitId;
    if (operatorId == null || unitId == null) {
      return;
    }

    setState(() => _loading = true);
    try {
      final service = ref.read(mdtServiceProvider);
      await service.refreshSystemAssignments(
        operatorId: operatorId,
        unitId: unitId,
      );
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _logRadioAssignment() async {
    final titleController = TextEditingController();
    final detailsController = TextEditingController();

    final create = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Radio Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: detailsController,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
          ],
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

    if (create != true) {
      return;
    }

    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) {
      return;
    }

    final service = ref.read(mdtServiceProvider);
    await service.createRadioAssignment(
      operatorId: session.operatorId!,
      unitId: session.unitId!,
      title: titleController.text.trim(),
      details: detailsController.text.trim().isEmpty
          ? null
          : detailsController.text.trim(),
    );
    await _reload();
  }

  Future<void> _decide(
    Assignment assignment,
    AssignmentDecision decision,
  ) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${decision.name.toUpperCase()} Assignment'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm != true || reasonController.text.trim().isEmpty) {
      return;
    }

    final session = ref.read(sessionProvider);
    if (session.operatorId == null || session.unitId == null) {
      return;
    }

    final service = ref.read(mdtServiceProvider);
    await service.decideAssignment(
      operatorId: session.operatorId!,
      unitId: session.unitId!,
      assignment: assignment,
      decision: decision,
      reason: reasonController.text.trim(),
    );

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Decision logged locally and queued for sync.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispatch Inbox')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _refreshSystemAssignments,
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('Refresh System'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _logRadioAssignment,
                    icon: const Icon(Icons.radio),
                    label: const Text('Log Radio'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _assignments.isEmpty
                ? const Center(child: Text('No assignments available.'))
                : ListView.builder(
                    itemCount: _assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = _assignments[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assignment.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text('Source: ${assignment.source.name.toUpperCase()}'),
                              Text('State: ${assignment.serverState}'),
                              Text('Version: ${assignment.version}'),
                              if (assignment.details != null)
                                Text('Details: ${assignment.details}'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () => _decide(
                                        assignment,
                                        AssignmentDecision.accept,
                                      ),
                                      child: const Text('Accept'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _decide(
                                        assignment,
                                        AssignmentDecision.reject,
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
