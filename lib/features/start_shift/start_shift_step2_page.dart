import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ptba_mdt/app/providers.dart';
import 'package:ptba_mdt/app/routes.dart';
import 'package:ptba_mdt/app/theme/theme.dart';
import 'package:ptba_mdt/features/shift/shift_controller.dart';
import 'package:ptba_mdt/features/start_shift/start_shift_form_controller.dart';
import 'package:ptba_mdt/features/start_shift/start_shift_form_state.dart';

/// Step 2 of 2 — Hourmeter input.
///
/// Displays the selected unit, prefills hmStart from the last known HM
/// (fetched asynchronously from storage), and submits the shift on "Mulai".
class StartShiftStep2Page extends ConsumerStatefulWidget {
  const StartShiftStep2Page({super.key});

  @override
  ConsumerState<StartShiftStep2Page> createState() =>
      _StartShiftStep2PageState();
}

class _StartShiftStep2PageState extends ConsumerState<StartShiftStep2Page>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hmStartController;
  bool _isSubmitting = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _hmStartController = TextEditingController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Trigger last-HM fetch after the first frame so the provider is
    // guaranteed to be listened before the state update fires.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(startShiftFormControllerProvider.notifier).fetchLastHm();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _hmStartController.dispose();
    super.dispose();
  }

  // ─── Submit ────────────────────────────────────────────────────────────

  Future<void> _onMulai() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    final formState = ref.read(startShiftFormControllerProvider);
    final hmStart = double.parse(_hmStartController.text.trim());

    unawaited(
      ref
          .read(operatorActivityApiProvider)
          .postInteraction(
            action: 'start_shift_step2_submitted',
            unitId: formState.unitId,
            operatorId: formState.operatorId,
            metadata: {'hmStart': hmStart},
          ),
    );

    setState(() => _isSubmitting = true);

    final success = await ref
        .read(shiftControllerProvider.notifier)
        .startShift(
          unitId: formState.unitId,
          operatorId: formState.operatorId,
          hmStart: hmStart,
        );

    if (!mounted) return;

    if (success) {
      // Clean up form state — shift is started, no longer needed.
      ref.read(startShiftFormControllerProvider.notifier).reset();

      // Remove entire back-stack; MainActivityPage becomes the only route.
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.mainActivity,
        (route) => false,
      );
    } else {
      setState(() => _isSubmitting = false);
      final error = ref.read(shiftControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal memulai shift'),
          backgroundColor: MdtTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(startShiftFormControllerProvider);

    // Prefill the HM field once the async fetch resolves.
    ref.listen<StartShiftFormState>(startShiftFormControllerProvider, (
      prev,
      next,
    ) {
      if (prev?.isLoadingHm == true &&
          !next.isLoadingHm &&
          next.lastHm != null &&
          _hmStartController.text.isEmpty) {
        _hmStartController.text = next.lastHm!.toStringAsFixed(1);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F4F8), Color(0xFFE4EAF0), Color(0xFFF7F8FA)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: SizedBox(
                        width: 520,
                        child: Form(
                          key: _formKey,
                          child: _buildCard(formState),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'V 1.0',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: MdtTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(StartShiftFormState formState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E4E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Unit badge ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: MdtTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: MdtTheme.primaryBlue.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                'NOMOR UNIT : ${formState.unitId}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: MdtTheme.primaryBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Operator label ──
            Text(
              formState.operatorId,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: MdtTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // ── Step indicator ──
            const _StepIndicator(currentStep: 2),
            const SizedBox(height: 28),

            // ── Hourmeter Awal ──
            _FieldLabel(text: 'Hourmeter Awal'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hmStartController,
              decoration: _hmInputDecoration(formState.isLoadingHm),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$')),
              ],
              textInputAction: TextInputAction.done,
              style: _inputTextStyle,
              onFieldSubmitted: (_) => _onMulai(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Hourmeter wajib diisi';
                }
                final parsed = double.tryParse(v.trim());
                if (parsed == null) return 'Format tidak valid';
                if (parsed <= 0) return 'Hourmeter harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 28),

            // ── Action buttons ──
            Row(
              children: [
                // Secondary: Kembali
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              final formState = ref.read(
                                startShiftFormControllerProvider,
                              );
                              unawaited(
                                ref
                                    .read(operatorActivityApiProvider)
                                    .postInteraction(
                                      action: 'start_shift_step2_back_tapped',
                                      unitId: formState.unitId,
                                      operatorId: formState.operatorId,
                                      metadata: const {},
                                    ),
                              );
                              Navigator.pop(context);
                            },
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Kembali'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDDE1E6)),
                        foregroundColor: MdtTheme.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Primary: Mulai
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _onMulai,
                      style: _primaryButtonStyle,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow_rounded, size: 22),
                                SizedBox(width: 8),
                                Text('Mulai Shift'),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared Styles ──────────────────────────────────────────────────────

  InputDecoration _hmInputDecoration(bool isLoadingHm) => InputDecoration(
    hintText: isLoadingHm
        ? 'Memuat hourmeter terakhir...'
        : 'Masukan Hourmeter',
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: MdtTheme.textHint,
    ),
    suffixIcon: isLoadingHm
        ? const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: MdtTheme.primaryBlue,
              ),
            ),
          )
        : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDDE1E6)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDDE1E6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: MdtTheme.primaryBlue, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
    ),
  );

  TextStyle get _inputTextStyle => TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: MdtTheme.textPrimary,
  );

  ButtonStyle get _primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: MdtTheme.primaryColor,
    foregroundColor: Colors.white,
    disabledBackgroundColor: MdtTheme.primaryColor.withValues(alpha: 0.6),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );
}

// ─── Shared subwidgets ───────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final isActive = (i + 1) == currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? MdtTheme.primaryBlue : const Color(0xFFDDE1E6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: MdtTheme.textSecondary,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFE74C3C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
