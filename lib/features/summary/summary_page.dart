import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ptba_mdt/app/providers.dart';
import 'package:ptba_mdt/app/routes.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/models/shift_summary.dart';
import 'package:ptba_mdt/features/shift/shift_controller.dart';
import 'package:ptba_mdt/features/summary/summary_provider.dart';
import 'package:ptba_mdt/shared/utils/display_helpers.dart';

/// SummaryPage — reworked to match the compact summary card reference.
///
/// Keeps the existing app data, but presents it in a simpler 2-row summary
/// layout with a centered white card and a single primary action.
class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  void _openTimesheet(
    BuildContext context,
    WidgetRef ref,
    ShiftSession session,
  ) {
    unawaited(
      ref
          .read(operatorActivityApiProvider)
          .postInteraction(
            action: 'timesheet_opened_from_summary',
            shiftSessionId: session.shiftSessionId,
            unitId: session.unitId,
            operatorId: session.operatorId,
            metadata: const {},
          ),
    );
    Navigator.pushNamed(context, AppRoutes.timesheet);
  }

  Future<void> _startNewShift(
    BuildContext context,
    WidgetRef ref,
    ShiftSession session,
  ) async {
    unawaited(
      ref
          .read(operatorActivityApiProvider)
          .postInteraction(
            action: 'start_new_shift_tapped',
            shiftSessionId: session.shiftSessionId,
            unitId: session.unitId,
            operatorId: session.operatorId,
            metadata: const {},
          ),
    );

    await ref.read(shiftControllerProvider.notifier).resetForNewShift();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.startShift);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftState = ref.watch(shiftControllerProvider);
    final session = shiftState.shiftSession;
    final summaryAsync = ref.watch(summaryProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFDCE3EE),
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Color(0xFFC62828),
              ),
            ),
          ),
          data: (summary) => summary == null
              ? const Center(
                  child: Text(
                    'Tidak ada data ringkasan.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFF616161),
                    ),
                  ),
                )
              : _SummaryCardLayout(
                  session: session,
                  summary: summary,
                  onOpenTimesheet: () => _openTimesheet(context, ref, session),
                  onStartNewShift: () => _startNewShift(context, ref, session),
                ),
        ),
      ),
    );
  }
}

class _SummaryCardLayout extends StatelessWidget {
  final ShiftSession session;
  final ShiftSummary summary;
  final VoidCallback onOpenTimesheet;
  final Future<void> Function() onStartNewShift;

  const _SummaryCardLayout({
    required this.session,
    required this.summary,
    required this.onOpenTimesheet,
    required this.onStartNewShift,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 640;
    final horizontalPadding = isCompact ? 20.0 : 34.0;
    final verticalPadding = isCompact ? 24.0 : 30.0;

    final topMetrics = [
      _MetricData(
        label: 'Tanggal Shift',
        value: _formatShiftDate(session.shiftDate),
        icon: Icons.calendar_today_outlined,
      ),
      _MetricData(
        label: 'Operator ID',
        value: session.operatorId,
        icon: Icons.person_outline_rounded,
      ),
      _MetricData(
        label: 'Unit ID',
        value: session.unitId,
        icon: Icons.local_shipping_outlined,
      ),
      _MetricData(
        label: 'HM Mulai',
        value: summary.hmStart.toStringAsFixed(1),
        icon: Icons.speed_rounded,
      ),
      _MetricData(
        label: 'HM Akhir',
        value: summary.hmEnd?.toStringAsFixed(1) ?? '—',
        icon: Icons.speed_outlined,
      ),
    ];

    final durationMetrics = [
      _MetricData(
        label: 'Operation',
        value: formatElapsed(summary.totalOperationSeconds),
        icon: Icons.access_time_rounded,
      ),
      _MetricData(
        label: 'Standby',
        value: formatElapsed(summary.totalStandbySeconds),
        icon: Icons.access_time_rounded,
      ),
      _MetricData(
        label: 'Delay',
        value: formatElapsed(summary.totalDelaySeconds),
        icon: Icons.access_time_rounded,
      ),
      _MetricData(
        label: 'Breakdown',
        value: formatElapsed(summary.totalBreakdownSeconds),
        icon: Icons.access_time_rounded,
      ),
      _MetricData(
        label: 'Total Shift',
        value: formatElapsed(summary.totalShiftSeconds),
        icon: Icons.access_time_filled_rounded,
      ),
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD9DEE7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SvgPicture.asset(
                          'assets/logo.svg',
                          width: isCompact ? 132 : 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    _HeaderActionButton(
                      icon: Icons.table_chart_outlined,
                      tooltip: 'Lihat Timesheet',
                      onTap: onOpenTimesheet,
                    ),
                    const SizedBox(width: 10),
                    const _HeaderStatusIcon(
                      icon: Icons.signal_cellular_alt_rounded,
                    ),
                    const SizedBox(width: 10),
                    const _HeaderStatusIcon(icon: Icons.battery_full_rounded),
                  ],
                ),
                SizedBox(height: isCompact ? 28 : 38),
                Text(
                  'Ringkasan Pekerjaan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isCompact ? 28 : 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF14171F),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Data di bawah menggunakan hasil aktivitas operator pada shift yang baru selesai.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6D7280),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: isCompact ? 24 : 30),
                _MetricGrid(items: topMetrics),
                const SizedBox(height: 20),
                _MetricGrid(items: durationMetrics),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InsightChip(
                      label: 'Delta HM',
                      value: summary.totalDeltaHm?.toStringAsFixed(1) ?? '—',
                    ),
                    _InsightChip(
                      label: 'PA',
                      value: summary.pa != null
                          ? '${summary.pa!.toStringAsFixed(1)}%'
                          : '—',
                    ),
                    _InsightChip(
                      label: 'UA',
                      value: summary.ua != null
                          ? '${summary.ua!.toStringAsFixed(1)}%'
                          : '—',
                    ),
                    _InsightChip(
                      label: 'Loading',
                      value: '${summary.loadingCountTotal} trip',
                    ),
                    _InsightChip(
                      label: 'Hauling',
                      value: '${summary.haulingCountTotal} trip',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onOpenTimesheet,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Lihat Timesheet Detail'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF344689),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onStartNewShift,
                    icon: const Icon(Icons.login_rounded, size: 20),
                    label: const Text('Mulai Shift Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF141B33),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatShiftDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return formatDate(parsed);
  }
}

class _MetricGrid extends StatelessWidget {
  final List<_MetricData> items;

  const _MetricGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 840
            ? 5
            : width >= 620
            ? 3
            : 2;
        const gap = 14.0;
        final itemWidth = (width - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: 18,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _MetricTile(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final _MetricData item;

  const _MetricTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(item.icon, size: 28, color: const Color(0xFF333333)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7A7A7A),
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightChip extends StatelessWidget {
  final String label;
  final String value;

  const _InsightChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E6F0)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF6D7280),
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C2338),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 20, color: const Color(0xFF2E3553)),
          ),
        ),
      ),
    );
  }
}

class _HeaderStatusIcon extends StatelessWidget {
  final IconData icon;

  const _HeaderStatusIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 24, color: const Color(0xFF333333));
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;

  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
  });
}
