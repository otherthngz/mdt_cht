import 'package:flutter/material.dart';

/// CategoryButton — per 08_COMPONENT_SPEC.md §5.3.
///
/// Inputs: label, isActive, accentColor, onTap
/// Behavior: triggers intent only
///
/// Enhanced with press animation and active glow effect.
class CategoryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color accentColor;
  final VoidCallback? onTap;

  const CategoryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.accentColor,
    this.onTap,
  });

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleController.forward();
  void _onTapUp(_) => _scaleController.reverse();
  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Material(
          color: widget.isActive
              ? widget.accentColor.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: widget.isActive ? 0 : 1,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: widget.accentColor.withValues(alpha: 0.2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isActive
                      ? widget.accentColor
                      : Colors.grey.shade200,
                  width: widget.isActive ? 2.5 : 1,
                ),
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 32,
                    color: widget.isActive
                        ? widget.accentColor
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: widget.isActive
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: widget.isActive
                          ? widget.accentColor
                          : const Color(0xFF424242),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
