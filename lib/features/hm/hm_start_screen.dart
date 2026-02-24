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
        // BUG-1 fix: use session.unitId; fall back to POC default only if not set
        final unitId = session.unitId ?? 'H515';
        final sessionId = await service.submitPreShiftHourmeter(
          operatorId: session.operatorId!,
          unitId: unitId,
          hmMulai: hmValue,
        );
        ref.read(sessionProvider.notifier).startShift(
              unitId: unitId,
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
    final session = ref.watch(sessionProvider);
    final unitId = session.unitId ?? 'H515';
    final operatorId = session.operatorId ?? '-';
    // BUG-10 / LOGIC-4 fix: dynamic titles based on mode and session
    final title = isHmMulai ? 'CN UNIT : $unitId' : 'HM Akhir — $unitId';
    final heading = isHmMulai ? 'CN UNIT : $unitId' : 'Akhiri Shift — $unitId';
    final greeting = isHmMulai
        ? 'Halo $operatorId! Silahkan masukan data terkini dengan benar'
        : 'Operator $operatorId, masukan Hourmeter akhir shift.';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Card(
          child: SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    heading,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    greeting,
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
