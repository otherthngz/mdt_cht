import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/mdt_service.dart';
import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';

class SelectUnitScreen extends ConsumerStatefulWidget {
  const SelectUnitScreen({super.key});

  @override
  ConsumerState<SelectUnitScreen> createState() => _SelectUnitScreenState();
}

class _SelectUnitScreenState extends ConsumerState<SelectUnitScreen> {
  static const _units = ['DT-101', 'DT-102', 'EX-301', 'GR-220'];
  String? _selected;
  bool _submitting = false;

  Future<void> _confirm(MdtService service) async {
    final session = ref.read(sessionProvider);
    final operatorId = session.operatorId;
    final unitId = _selected;
    if (operatorId == null || unitId == null) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await service.selectUnit(operatorId: operatorId, unitId: unitId);
      ref.read(sessionProvider.notifier).setUnit(unitId);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.hmStart);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final service = ref.watch(mdtServiceProvider);

    if (!session.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Unit')),
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false),
            child: const Text('Back to Login'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select Unit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._units.map(
              (unit) => RadioListTile<String>(
                title: Text(unit),
                value: unit,
                groupValue: _selected,
                onChanged: (value) => setState(() => _selected = value),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting || _selected == null
                    ? null
                    : () => _confirm(service),
                child: Text(_submitting ? 'Saving...' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
