import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ptba_mdt/domain/models/timesheet_row.dart';
import 'package:ptba_mdt/features/timesheet/timesheet_provider.dart';
import 'package:ptba_mdt/shared/utils/display_helpers.dart';

/// TimesheetPage — per 08_COMPONENT_SPEC.md §4.3.
///
/// Purpose: Display activity audit log as a scrollable table.
/// Columns: Start/End Timestamp, Category (tinted), Activity,
///          Start HM, End HM, Delta HM, Stockpile,
///          Loading Count, Dumping Count, Loader Number.
class TimesheetPage extends ConsumerStatefulWidget {
  const TimesheetPage({super.key});

  @override
  ConsumerState<TimesheetPage> createState() => _TimesheetPageState();
}

class _TimesheetPageState extends ConsumerState<TimesheetPage> {
  Timer? _refreshTimer;

  // ── Column definitions ──────────────────────────────────────────────
  static const _headers = [
    'Start\nTimestamp',
    'End\nTimestamp',
    'Category',
    'Activity',
    'Start\nHM',
    'End\nHM',
    'Delta\nHM',
    'Stockpile',
    'Loading\nCount',
    'Dumping\nCount',
    'Loader\nNumber',
  ];

  static const _colWidths = <double>[
    100, // Start Timestamp
    100, // End Timestamp
    110, // Category
    140, // Activity
    90,  // Start HM
    90,  // End HM
    90,  // Delta HM
    100, // Stockpile
    100, // Loading Count
    110, // Dumping Count
    120, // Loader Number
  ];

  static double get _totalWidth =>
      _colWidths.fold(0, (sum, w) => sum + w);

  @override
  void initState() {
    super.initState();
    // Refresh every second to keep active row timer live
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _formatTime(String isoString) {
    final dt = DateTime.parse(isoString);
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final timesheetAsync = ref.watch(timesheetProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Title row ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  const Text(
                    'Timesheet Aktivitas',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close_rounded,
                        size: 26, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

            // ── Table ──
            Expanded(
              child: timesheetAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(
                          color: Colors.red, fontSize: 16)),
                ),
                data: (rows) => _buildTable(rows),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Table layout ──────────────────────────────────────────────────

  Widget _buildTable(List<TimesheetRow> rows) {
    if (rows.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada aktivitas tercatat.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF616161),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _totalWidth,
        child: Column(
          children: [
            _buildHeaderRow(),
            const Divider(
                height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (_, i) => _buildDataRow(rows[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header row ────────────────────────────────────────────────────

  Widget _buildHeaderRow() {
    return Row(
      children: List.generate(_headers.length, (i) {
        return _Cell(
          width: _colWidths[i],
          borderRight: i < _headers.length - 1,
          color: Colors.white,
          child: Text(
            _headers[i],
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        );
      }),
    );
  }

  // ── Data row ─────────────────────────────────────────────────────

  Widget _buildDataRow(TimesheetRow row) {
    final color = categoryColor(row.category);

    final endTimeStr =
        row.endTime != null ? _formatTime(row.endTime!) : '—';

    final hmStart = row.hmStartDerived != null
        ? row.hmStartDerived!.toStringAsFixed(1)
        : '—';
    final hmEnd =
        row.hmEndDerived != null ? row.hmEndDerived!.toStringAsFixed(1) : '—';
    final deltaHm = row.deltaHmDerived != null
        ? row.deltaHmDerived!.toStringAsFixed(1)
        : '—';

    final cells = [
      _formatTime(row.startTime),     // Start Timestamp
      endTimeStr,                      // End Timestamp
      categoryDisplayLabel(row.category), // Category (tinted)
      subtypeDisplayLabel(row.activity),  // Activity
      hmStart,                         // Start HM
      hmEnd,                           // End HM
      deltaHm,                         // Delta HM
      row.haulingCode ?? '—',          // Stockpile
      '${row.loadingCount}',           // Loading Count
      '${row.haulingCount}',           // Dumping Count
      row.loaderCode ?? '—',           // Loader Number
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(cells.length, (i) {
            final isCategory = i == 2;
            return _Cell(
              width: _colWidths[i],
              borderRight: i < cells.length - 1,
              color: isCategory ? color.withValues(alpha: 0.12) : Colors.white,
              child: Text(
                cells[i],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight:
                      isCategory ? FontWeight.w500 : FontWeight.w400,
                  color:
                      isCategory ? color : const Color(0xFF1F2937),
                ),
              ),
            );
          }),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

// ── Reusable table cell ─────────────────────────────────────────────────

class _Cell extends StatelessWidget {
  final double width;
  final bool borderRight;
  final Color color;
  final Widget child;

  const _Cell({
    required this.width,
    required this.borderRight,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        border: borderRight
            ? const Border(
                right: BorderSide(color: Color(0xFFE5E7EB)),
              )
            : null,
      ),
      child: child,
    );
  }
}
