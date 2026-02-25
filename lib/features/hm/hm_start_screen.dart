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
    final greeting = isHmMulai
        ? 'Halo $operatorId! Silahkan masukan data terkini dengan benar'
        : 'Operator $operatorId, masukan Hourmeter akhir shift.';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isHmMulai
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: const BackButton(
                color: Color(0xFF1B2A4A),
              ),
              title: Text(
                'HM Akhir',
                style: const TextStyle(
                  color: Color(0xFF1B2A4A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo centered ──
                    Image.asset(
                      'assets/logo.png',
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),

                    // ── Title ──
                    Text(
                      'CN UNIT : $unitId',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Subtitle / Greeting ──
                    Text.rich(
                      TextSpan(
                        children: isHmMulai
                            ? [
                                const TextSpan(text: 'Halo '),
                                TextSpan(
                                  text: operatorId,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                const TextSpan(
                                    text:
                                        '! Silahkan masukan data terkini dengan benar'),
                              ]
                            : [
                                const TextSpan(text: 'Operator '),
                                TextSpan(
                                  text: operatorId,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                const TextSpan(
                                    text:
                                        ', masukan Hourmeter akhir shift.'),
                              ],
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Label ──
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Masukan Hourmeter',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ── Input field ──
                    SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _hmController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1B2A4A),
                        ),
                        decoration: InputDecoration(
                          hintText: '0000',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                          suffixText: 'JAM',
                          suffixStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade500,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Submit button (dark navy/black) ──
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2A4A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFF1B2A4A).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _saving
                              ? 'Memproses...'
                              : isHmMulai
                                  ? 'Masuk'
                                  : 'Konfirmasi',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // ── Logout link (HM Mulai only) ──
                    if (isHmMulai) ...[
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: _saving ? null : _logout,
                        icon: const Icon(
                          Icons.logout,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
