import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/routes.dart';
import '../../app/session_state.dart';

enum CnUnitFormMode { hmMulai, hmAkhir }

class CnUnitFormScreen extends ConsumerStatefulWidget {
  const CnUnitFormScreen({
    super.key,
    required this.mode,
  });

  final CnUnitFormMode mode;

  @override
  ConsumerState<CnUnitFormScreen> createState() => _CnUnitFormScreenState();
}

class _CnUnitFormScreenState extends ConsumerState<CnUnitFormScreen> {
  final _hmController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _hmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final session = ref.read(sessionProvider);
    final hmValue = double.tryParse(_hmController.text.trim());
    if (session.operatorId == null || hmValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukan Hourmeter wajib angka.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final service = ref.read(mdtServiceProvider);
      if (widget.mode == CnUnitFormMode.hmMulai) {
        final sessionId = await service.submitPreShiftHourmeter(
          operatorId: session.operatorId!,
          unitId: 'H515',
          hmMulai: hmValue,
        );
        ref.read(sessionProvider.notifier).startShift(
              unitId: 'H515',
              sessionId: sessionId,
              hmStart: hmValue,
              shiftStartedAtUtc: DateTime.now().toUtc(),
            );
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(AppRoutes.p2h);
      } else {
        if (session.unitId == null ||
            session.shiftSessionId == null ||
            session.hmStart == null) {
          throw ArgumentError('Sesi shift tidak tersedia.');
        }
        await service.submitPostShiftHourmeter(
          operatorId: session.operatorId!,
          unitId: session.unitId!,
          shiftSessionId: session.shiftSessionId!,
          hmMulai: session.hmStart!,
          hmAkhir: hmValue,
        );
        ref.read(sessionProvider.notifier).setHmEnd(hmValue);
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(AppRoutes.ringkasan);
      }
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

  Future<void> _logout() async {
    final session = ref.read(sessionProvider);
    if (session.operatorId != null) {
      await ref.read(mdtServiceProvider).recordLogout(
            operatorId: session.operatorId!,
            unitId: session.unitId,
          );
    }
    ref.read(sessionProvider.notifier).resetAll();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isHmMulai = widget.mode == CnUnitFormMode.hmMulai;

    return Scaffold(
      appBar: AppBar(title: const Text('CN UNIT : H515')),
      body: Center(
        child: Card(
          child: SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'CN UNIT : H515',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Halo AERI! Silahkan masukan data terkini dengan benar',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _hmController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Masukan Hourmeter',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: Text(_saving
                          ? 'Memproses...'
                          : isHmMulai
                              ? 'Masuk'
                              : 'Konfirmasi'),
                    ),
                  ),
                  if (isHmMulai)
                    TextButton(
                      onPressed: _saving ? null : _logout,
                      child: const Text('Logout'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
