import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ptba_mdt/app/routes.dart';
import 'package:ptba_mdt/app/theme/theme.dart';
import 'package:ptba_mdt/features/start_shift/start_shift_form_controller.dart';

/// Step 1 of 2 — Unit & Operator input.
///
/// Saves values to [StartShiftFormController] and navigates to Step 2.
/// Restores previously entered values when navigating back.
class StartShiftStep1Page extends ConsumerStatefulWidget {
  const StartShiftStep1Page({super.key});

  @override
  ConsumerState<StartShiftStep1Page> createState() =>
      _StartShiftStep1PageState();
}

class _StartShiftStep1PageState extends ConsumerState<StartShiftStep1Page>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _unitIdController;
  late final TextEditingController _operatorIdController;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Restore values when navigating back from Step 2.
    final saved = ref.read(startShiftFormControllerProvider);
    _unitIdController = TextEditingController(text: saved.unitId);
    _operatorIdController = TextEditingController(text: saved.operatorId);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _unitIdController.dispose();
    _operatorIdController.dispose();
    super.dispose();
  }

  void _onLanjut() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(startShiftFormControllerProvider.notifier).setStep1(
          unitId: _unitIdController.text.trim(),
          operatorId: _operatorIdController.text.trim(),
        );

    Navigator.pushNamed(context, AppRoutes.startShiftStep2);
  }

  @override
  Widget build(BuildContext context) {
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
                          horizontal: 24, vertical: 32),
                      child: SizedBox(
                        width: 520,
                        child: Form(
                          key: _formKey,
                          child: _buildCard(),
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

  Widget _buildCard() {
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
            // ── Logo ──
            SvgPicture.asset('assets/logo.svg', width: 180, height: 56),
            const SizedBox(height: 16),

            // ── Subtitle ──
            Text(
              'Masukkan data unit dan operator\nsebelum memulai pekerjaan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: MdtTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // ── Step indicator ──
            const _StepIndicator(currentStep: 1),
            const SizedBox(height: 28),

            // ── Nomor Unit ──
            _FieldLabel(text: 'Nomor Unit'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _unitIdController,
              decoration: _inputDecoration('Masukan Nomor Unit'),
              textInputAction: TextInputAction.next,
              style: _inputTextStyle,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nomor Unit wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Nomor ID ──
            _FieldLabel(text: 'Nomor ID'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _operatorIdController,
              decoration: _inputDecoration('Masukan Nomor ID'),
              textInputAction: TextInputAction.done,
              style: _inputTextStyle,
              onFieldSubmitted: (_) => _onLanjut(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nomor ID wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // ── Lanjut button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onLanjut,
                style: _primaryButtonStyle,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lanjut'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared Styles ───────────────────────────────────────────────────

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: MdtTheme.textHint,
        ),
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

/// Two-dot animated step indicator.
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
              color: isActive
                  ? MdtTheme.primaryBlue
                  : const Color(0xFFDDE1E6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

/// Label with a red required asterisk.
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
