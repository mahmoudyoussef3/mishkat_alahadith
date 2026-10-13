import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The small colour square that keys a tajweed rule.
class RuleSwatch extends StatelessWidget {
  final Color color;
  final double size;

  const RuleSwatch({super.key, required this.color, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size.r * 0.3),
      ),
    );
  }
}

/// A rule's swatch in a well tinted with its colour, at the start of a row.
class RuleWell extends StatelessWidget {
  final Color color;
  final double size;

  const RuleWell({super.key, required this.color, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size.r * 0.32),
      ),
      child: RuleSwatch(color: color, size: size * 0.37),
    );
  }
}
