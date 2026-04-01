import 'package:flutter/material.dart';
import 'package:ptba_mdt/domain/models/enums.dart';
import 'package:ptba_mdt/shared/utils/display_helpers.dart';

/// SubActivitySheet — per 08_COMPONENT_SPEC.md §5.5.
///
/// Purpose: Select activity subtype
/// Inputs: category, currentSubtype
/// Output: → triggers ACTIVITY_STARTED
class SubActivitySheet extends StatelessWidget {
  final String category;
  final String? currentSubtype;

  const SubActivitySheet({
    super.key,
    required this.category,
    this.currentSubtype,
  });

  /// Show as a dialog and return the selected subtype string, or null.
  static Future<String?> show(
    BuildContext context, {
    required String category,
    String? currentSubtype,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => SubActivitySheet(
        category: category,
        currentSubtype: currentSubtype,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category);
    final catLabel = categoryDisplayLabel(category);

    final activityCategory = ActivityCategory.values.firstWhere(
      (c) => c.name == category,
      orElse: () => ActivityCategory.operation,
    );
    final subtypes = categorySubtypes[activityCategory] ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      catLabel,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, null),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    color: Colors.grey.shade500,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── 3-column grid (3×2 for 6 items, 3×2 for 4 items) ──
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: subtypes.length,
                itemBuilder: (context, index) {
                  final subtype = subtypes[index];
                  final subtypeStr = subtypeToString(subtype);
                  final isActive = subtypeStr == currentSubtype;
                  final label = subtypeDisplayLabel(subtypeStr).toUpperCase();

                  return GestureDetector(
                    onTap: () => Navigator.pop(context, subtypeStr),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive ? color : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? color
                                  : const Color(0xFF0F172A),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
