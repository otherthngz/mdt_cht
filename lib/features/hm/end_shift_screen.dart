import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/mdt_service.dart';
import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';

class EndShiftScreen extends ConsumerStatefulWidget {
  const EndShiftScreen({super.key});

  @override
  ConsumerState<EndShiftScreen> createState() => _EndShiftScreenState();
}

class _EndShiftScreenState extends ConsumerState<EndShiftScreen> {
  final _hmEndController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _hmEndController.dispose();
    super.dispose();
  }

  Future<void> _submit(MdtService service) async {
    final session = ref.read(sessionProvider);
    final hmEnd = double.tryParse(_hmEndController.text.trim());

    if (session.operatorId == null ||
        session.unitId == null ||
        session.shiftSessionId == null ||
        hmEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing shift session or HM end value.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await service.endShift(
        operatorId: session.operatorId!,
        unitId: session.unitId!,
        shiftSessionId: session.shiftSessionId!,
        hmEnd: hmEnd,
      );
      ref.read(sessionProvider.notifier).clearShift();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift ended and events queued.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (_) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(mdtServiceProvider);
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('End Shift + HM End')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operator: ${session.operatorId ?? '-'}'),
            Text('Unit: ${session.unitId ?? '-'}'),
            Text('Shift Session: ${session.shiftSessionId ?? '-'}'),
            const SizedBox(height: 12),
            TextField(
              controller: _hmEndController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'HM End',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : () => _submit(service),
                child: Text(_saving ? 'Saving...' : 'End Shift'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
