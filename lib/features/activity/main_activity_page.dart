import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ptba_mdt/app/routes.dart';
import 'package:ptba_mdt/features/shift/shift_controller.dart';
import 'package:ptba_mdt/shared/utils/display_helpers.dart';
import 'package:ptba_mdt/shared/widgets/sub_activity_sheet.dart';
import 'package:ptba_mdt/shared/widgets/code_input_modal.dart';
import 'package:ptba_mdt/shared/widgets/end_shift_modal.dart';

/// MainActivityPage — redesigned layout.
///
/// ┌─────────────────────────────────────────────────────┐
/// │ Status Saat ini  🕐              [→] AKHIRI SHIFT    │ ← header
/// ├─────────────────────────────────────────────────────┤
/// │                                                     │
/// │              ┌─────────────────────┐               │
/// │              │    CHANGE SHIFT     │  ← activity   │
/// │              └─────────────────────┘               │
/// │                    00:27:23          ← timer        │
/// │                                                     │
/// ├───────────┬────────────┬──────────┬─────────────────┤
/// │ OPERATION │  STANDBY   │  DELAY   │   BREAKDOWN     │ ← category bar
/// └───────────┴────────────┴──────────┴─────────────────┘
class MainActivityPage extends ConsumerStatefulWidget {
  const MainActivityPage({super.key});

  @override
  ConsumerState<MainActivityPage> createState() => _MainActivityPageState();
}

class _MainActivityPageState extends ConsumerState<MainActivityPage> {
  Timer? _timerTick;
  int _elapsedSeconds = 0;
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _computeElapsed();
    _timerTick = Timer.periodic(const Duration(seconds: 1), (_) {
      _computeElapsed();
    });
  }

  @override
  void dispose() {
    _timerTick?.cancel();
    super.dispose();
  }

  void _computeElapsed() {
    final startedAt =
        ref.read(shiftControllerProvider).currentActivityStartedAt;
    if (startedAt == null) {
      setState(() => _elapsedSeconds = 0);
      return;
    }
    final diff =
        DateTime.now().difference(DateTime.parse(startedAt)).inSeconds;
    setState(() => _elapsedSeconds = diff < 0 ? 0 : diff);
  }

  // ─── Activity switching ───────────────────────────────────────────────

  Future<void> _onCategoryTap(String category) async {
    if (_isSwitching) return;

    final shiftState = ref.read(shiftControllerProvider);
    final selectedSubtype = await SubActivitySheet.show(
      context,
      category: category,
      currentSubtype: shiftState.currentSubtype,
    );

    if (!mounted || selectedSubtype == null) return;
    if (selectedSubtype == shiftState.currentSubtype) return;

    if (selectedSubtype == 'loading') {
      await _handleCodeInput(category, selectedSubtype, isLoading: true);
    } else if (selectedSubtype == 'hauling') {
      await _handleCodeInput(category, selectedSubtype, isLoading: false);
    } else {
      await _doSwitch(newCategory: category, newSubtype: selectedSubtype);
    }
  }

  Future<void> _handleCodeInput(
    String category,
    String subtype, {
    required bool isLoading,
  }) async {
    final code = await CodeInputModal.show(context, subtype);
    if (!mounted || code == null) return;
    await _doSwitch(
      newCategory: category,
      newSubtype: subtype,
      loaderCode: isLoading ? code : null,
      haulingCode: isLoading ? null : code,
    );
  }

  Future<void> _doSwitch({
    required String newCategory,
    required String newSubtype,
    String? loaderCode,
    String? haulingCode,
  }) async {
    setState(() => _isSwitching = true);

    final success = await ref
        .read(shiftControllerProvider.notifier)
        .switchActivity(
          newCategory: newCategory,
          newSubtype: newSubtype,
          loaderCode: loaderCode,
          haulingCode: haulingCode,
        );

    if (mounted) {
      setState(() => _isSwitching = false);
      if (!success) {
        final error = ref.read(shiftControllerProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(error), behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }

  // ─── End shift & timesheet ───────────────────────────────────────────

  Future<void> _onEndShiftTap() async {
    final session = ref.read(shiftControllerProvider).shiftSession;
    if (session == null) return;
    final hmEnd =
        await EndShiftModal.show(context, hmStart: session.hmStart);
    if (!mounted || hmEnd == null) return;
    final success = await ref
        .read(shiftControllerProvider.notifier)
        .endShift(hmEnd: hmEnd);
    if (mounted && success) {
      Navigator.pushReplacementNamed(context, AppRoutes.shiftEnded);
    }
  }

  void _onTimesheetTap() =>
      Navigator.pushNamed(context, AppRoutes.timesheet);

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final shiftState = ref.watch(shiftControllerProvider);
    final session = shiftState.shiftSession;

    if (session == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final activityColor = categoryColor(shiftState.currentCategory);
    final subtypeLabel =
        subtypeDisplayLabel(shiftState.currentSubtype).toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(),

            const Divider(height: 1, thickness: 1, color: Color(0xFFEBEEF2)),

            // ── Active activity display ──
            Expanded(
              child: _buildActivityDisplay(
                activityColor: activityColor,
                subtypeLabel: subtypeLabel,
                loaderCode: shiftState.currentLoaderCode,
                haulingCode: shiftState.currentHaulingCode,
              ),
            ),

            // ── Category bar ──
            _buildCategoryBar(shiftState.currentCategory),
          ],
        ),
      ),
    );
  }

  // ─── Header row ──────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Tapping the label opens the timesheet (history icon signals this)
          GestureDetector(
            onTap: _onTimesheetTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const Text(
                  'Status Saat ini',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.history_rounded,
                    size: 22, color: Colors.grey.shade600),
              ],
            ),
          ),
          const Spacer(),
          // AKHIRI SHIFT
          TextButton.icon(
            onPressed: _onEndShiftTap,
            icon: const Icon(Icons.logout_rounded,
                size: 20, color: Color(0xFFE63946)),
            label: const Text(
              'AKHIRI SHIFT',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE63946),
                letterSpacing: 0.5,
              ),
            ),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Activity display ─────────────────────────────────────────────────

  Widget _buildActivityDisplay({
    required Color activityColor,
    required String subtypeLabel,
    String? loaderCode,
    String? haulingCode,
  }) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F7FA),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Large activity pill ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              constraints: const BoxConstraints(maxWidth: 500),
              height: 100,
              decoration: BoxDecoration(
                color: activityColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  subtypeLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Timer ──
            Text(
              formatElapsed(_elapsedSeconds),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: Color(0xFF1A1A1A),
                letterSpacing: 3,
              ),
            ),

            // ── Code badge (loading / hauling only) ──
            if (loaderCode != null || haulingCode != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: activityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_rounded,
                        size: 16, color: activityColor),
                    const SizedBox(width: 8),
                    Text(
                      loaderCode != null
                          ? 'Loader: $loaderCode'
                          : 'Hauling: $haulingCode',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: activityColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Category bar ─────────────────────────────────────────────────────

  Widget _buildCategoryBar(String? currentCategory) {
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CategoryTile(
            label: 'OPERATION',
            color: categoryColor('operation'),
            isActive: currentCategory == 'operation',
            enabled: !_isSwitching,
            onTap: () => _onCategoryTap('operation'),
          ),
          _CategoryTile(
            label: 'STANDBY',
            color: categoryColor('standby'),
            isActive: currentCategory == 'standby',
            enabled: !_isSwitching,
            onTap: () => _onCategoryTap('standby'),
          ),
          _CategoryTile(
            label: 'DELAY',
            color: categoryColor('delay'),
            isActive: currentCategory == 'delay',
            enabled: !_isSwitching,
            onTap: () => _onCategoryTap('delay'),
          ),
          _CategoryTile(
            label: 'BREAKDOWN',
            color: categoryColor('breakdown'),
            isActive: currentCategory == 'breakdown',
            enabled: !_isSwitching,
            onTap: () => _onCategoryTap('breakdown'),
          ),
        ],
      ),
    );
  }
}

// ─── Category tile ─────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final bool enabled;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.label,
    required this.color,
    required this.isActive,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base color
            ColoredBox(
              color: enabled ? color : color.withValues(alpha: 0.65),
            ),
            // Label
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            // Active indicator: white bar across the top
            if (isActive)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
