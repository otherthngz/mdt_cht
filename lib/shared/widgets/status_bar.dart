import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ptba_mdt/app/theme/theme.dart';
import 'package:ptba_mdt/shared/utils/display_helpers.dart';

/// StatusBar — per 08_COMPONENT_SPEC.md §5.1.
///
/// Inputs: unitId, operatorId, currentTime
/// Notes: display-only, no logic
class StatusBar extends StatefulWidget {
  final String unitId;
  final String operatorId;

  const StatusBar({
    super.key,
    required this.unitId,
    required this.operatorId,
  });

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            MdtTheme.statusBarGradientStart,
            MdtTheme.statusBarGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Unit ID
          _StatusChip(
            icon: Icons.local_shipping,
            label: widget.unitId,
          ),

          const SizedBox(width: 24),

          // Operator ID
          _StatusChip(
            icon: Icons.person,
            label: widget.operatorId,
          ),

          const Spacer(),

          // Date
          _StatusChip(
            icon: Icons.calendar_today,
            label: formatDate(_now),
          ),

          const SizedBox(width: 20),

          // Live clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  formatClock(_now),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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

/// Small info chip in the status bar.
class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
