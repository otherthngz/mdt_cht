import 'package:flutter/material.dart';
import 'package:ptba_mdt/shared/utils/display_helpers.dart';
import 'package:ptba_mdt/shared/widgets/category_button.dart';

/// CategoryGrid — per 08_COMPONENT_SPEC §4.
///
/// A 2×2 grid of 4 CategoryButtons:
///   Operation | Standby
///   Delay     | Breakdown
///
/// Highlights the currently active category.
class CategoryGrid extends StatelessWidget {
  final String? currentCategory;
  final void Function(String category)? onCategoryTap;

  const CategoryGrid({
    super.key,
    this.currentCategory,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryDef('operation', 'Operasi', Icons.engineering),
      _CategoryDef('standby', 'Standby', Icons.hourglass_empty),
      _CategoryDef('delay', 'Delay', Icons.warning_amber_rounded),
      _CategoryDef('breakdown', 'Breakdown', Icons.build_circle),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: categories.map((cat) {
        final isActive = currentCategory == cat.key;
        return CategoryButton(
          label: cat.label,
          icon: cat.icon,
          isActive: isActive,
          accentColor: categoryColor(cat.key),
          onTap: onCategoryTap != null
              ? () => onCategoryTap!(cat.key)
              : null,
        );
      }).toList(),
    );
  }
}

class _CategoryDef {
  final String key;
  final String label;
  final IconData icon;
  const _CategoryDef(this.key, this.label, this.icon);
}
