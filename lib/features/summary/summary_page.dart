import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ptba_mdt/app/routes.dart';
import 'package:ptba_mdt/features/shift/shift_controller.dart';
import 'package:ptba_mdt/features/summary/summary_provider.dart';
import 'package:ptba_mdt/domain/models/shift_session.dart';
import 'package:ptba_mdt/domain/models/shift_summary.dart';
import 'package:ptba_mdt/shared/utils/display_helpers.dart';
import 'package:ptba_mdt/shared/widgets/status_bar.dart';

/// SummaryPage — per 08_COMPONENT_SPEC.md §4.4.
///
/// Purpose: Display shift metrics
/// Contains: Shift info section, SummaryMetricCards, PA/UA metrics,
///           SecondaryActionButton (View Timesheet),
///           PrimaryActionButton (Start New Shift)
/// Data Source: Derived ShiftSummary
class SummaryPage extends ConsumerWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftState = ref.watch(shiftControllerProvider);
    final session = shiftState.shiftSession;
    final summaryAsync = ref.watch(summaryProvider);

    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Status Bar ──
            StatusBar(
              unitId: session.unitId,
              operatorId: session.operatorId,
            ),

            // ── Main content ──
            Expanded(
              child: summaryAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Colors.red, fontSize: 16)),
                ),
                data: (summary) => summary == null
                    ? const Center(
                        child: Text('Tidak ada data',
                            style: TextStyle(fontSize: 16)))
                    : _buildContent(context, ref, session, summary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, ShiftSession session, ShiftSummary summary) {

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Title ──
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 28,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Shift',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212121),
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Shift telah berakhir',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Shift Info Card ──
          _ShiftInfoCard(
            unitId: session.unitId,
            operatorId: session.operatorId,
            shiftDate: session.shiftDate,
            hmStart: summary.hmStart,
            hmEnd: summary.hmEnd,
            totalDeltaHm: summary.totalDeltaHm,
          ),
          const SizedBox(height: 20),

          // ── PA / UA Cards ──
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'PA',
                  sublabel: 'Physical Availability',
                  value: summary.pa != null
                      ? '${summary.pa!.toStringAsFixed(1)}%'
                      : '—',
                  color: const Color(0xFF1565C0),
                  icon: Icons.verified_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  label: 'UA',
                  sublabel: 'Use of Availability',
                  value: summary.ua != null
                      ? '${summary.ua!.toStringAsFixed(1)}%'
                      : '—',
                  color: const Color(0xFF00838F),
                  icon: Icons.speed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Category Duration Breakdown ──
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Rincian Durasi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF424242),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DurationBar(summary: summary),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CategoryDurationTile(
                  label: 'Operasi',
                  seconds: summary.totalOperationSeconds,
                  color: categoryColor('operation'),
                  icon: categoryIcon('operation'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryDurationTile(
                  label: 'Standby',
                  seconds: summary.totalStandbySeconds,
                  color: categoryColor('standby'),
                  icon: categoryIcon('standby'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CategoryDurationTile(
                  label: 'Delay',
                  seconds: summary.totalDelaySeconds,
                  color: categoryColor('delay'),
                  icon: categoryIcon('delay'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryDurationTile(
                  label: 'Breakdown',
                  seconds: summary.totalBreakdownSeconds,
                  color: categoryColor('breakdown'),
                  icon: categoryIcon('breakdown'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Counts ──
          Row(
            children: [
              Expanded(
                child: _CountTile(
                  label: 'Loading',
                  count: summary.loadingCountTotal,
                  icon: Icons.download_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CountTile(
                  label: 'Hauling',
                  count: summary.haulingCountTotal,
                  icon: Icons.local_shipping,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Actions ──
          // SecondaryActionButton: View Timesheet (per §5.10)
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.timesheet);
            },
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('Lihat Timesheet Detail'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: BorderSide(color: Colors.grey.shade400),
              foregroundColor: const Color(0xFF424242),
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // PrimaryActionButton: Start New Shift (per §5.9)
          ElevatedButton.icon(
            onPressed: () async {
              await ref
                  .read(shiftControllerProvider.notifier)
                  .resetForNewShift();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.startShift);
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Mulai Shift Baru'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Subwidgets ─────────────────────────────────────────────────────────

class _ShiftInfoCard extends StatelessWidget {
  final String unitId;
  final String operatorId;
  final String shiftDate;
  final double hmStart;
  final double? hmEnd;
  final double? totalDeltaHm;

  const _ShiftInfoCard({
    required this.unitId,
    required this.operatorId,
    required this.shiftDate,
    required this.hmStart,
    this.hmEnd,
    this.totalDeltaHm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Unit ID', value: unitId),
          const SizedBox(height: 10),
          _InfoRow(label: 'Operator ID', value: operatorId),
          const SizedBox(height: 10),
          _InfoRow(label: 'Tanggal', value: shiftDate),
          const Divider(height: 20),
          _InfoRow(
            label: 'HM Awal',
            value: hmStart.toStringAsFixed(1),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'HM Akhir',
            value: hmEnd?.toStringAsFixed(1) ?? '—',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Total Delta HM',
            value: totalDeltaHm?.toStringAsFixed(1) ?? '—',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: const Color(0xFF212121),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationBar extends StatelessWidget {
  final ShiftSummary summary;

  const _DurationBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    final total = summary.totalShiftSeconds;
    if (total == 0) return const SizedBox(height: 12);

    final segments = [
      _BarSegment(
          summary.totalOperationSeconds / total, categoryColor('operation')),
      _BarSegment(
          summary.totalStandbySeconds / total, categoryColor('standby')),
      _BarSegment(summary.totalDelaySeconds / total, categoryColor('delay')),
      _BarSegment(
          summary.totalBreakdownSeconds / total, categoryColor('breakdown')),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 14,
        child: Row(
          children: segments
              .where((s) => s.fraction > 0)
              .map((s) => Expanded(
                    flex: (s.fraction * 1000).round().clamp(1, 1000),
                    child: Container(color: s.color),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _BarSegment {
  final double fraction;
  final Color color;
  const _BarSegment(this.fraction, this.color);
}

class _CategoryDurationTile extends StatelessWidget {
  final String label;
  final int seconds;
  final Color color;
  final IconData icon;

  const _CategoryDurationTile({
    required this.label,
    required this.seconds,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatElapsed(seconds),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;

  const _CountTile({
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF616161)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
              ),
              Text(
                '$count trip',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
