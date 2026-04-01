import 'package:flutter/material.dart';
import 'package:ptba_mdt/shared/utils/display_helpers.dart';

/// ActiveActivityCard — per 08_COMPONENT_SPEC.md §5.2.
///
/// Inputs (Derived):
/// - category, subtype, elapsedSeconds
/// - isActive, loaderCode, haulingCode
///
/// Notes:
/// - elapsedSeconds from controller
/// - no internal timer
class ActiveActivityCard extends StatefulWidget {
  final String? category;
  final String? subtype;
  final int elapsedSeconds;
  final bool isActive;
  final String? loaderCode;
  final String? haulingCode;

  const ActiveActivityCard({
    super.key,
    required this.category,
    required this.subtype,
    required this.elapsedSeconds,
    this.isActive = true,
    this.loaderCode,
    this.haulingCode,
  });

  @override
  State<ActiveActivityCard> createState() => _ActiveActivityCardState();
}

class _ActiveActivityCardState extends State<ActiveActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(widget.category);
    final catLabel = categoryDisplayLabel(widget.category);
    final subLabel = subtypeDisplayLabel(widget.subtype);
    final elapsed = formatElapsed(widget.elapsedSeconds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ──
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              if (widget.isActive) ...[
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: _pulseAnimation.value),
                        boxShadow: [
                          BoxShadow(
                            color:
                                color.withValues(alpha: _pulseAnimation.value * 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Aktivitas Saat Ini',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        // ── Card ──
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color, width: 2.5),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.08),
                  color.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // ── Category icon ──
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        categoryIcon(widget.category),
                        color: color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),

                    // ── Labels ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            catLabel,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: color,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subLabel,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Timer ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        elapsed,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Loader / Hauling Code (if applicable) ──
                if (widget.loaderCode != null ||
                    widget.haulingCode != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: color.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code, size: 18, color: color),
                        const SizedBox(width: 8),
                        Text(
                          widget.loaderCode != null
                              ? 'Loader: ${widget.loaderCode}'
                              : 'Hauling: ${widget.haulingCode}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
