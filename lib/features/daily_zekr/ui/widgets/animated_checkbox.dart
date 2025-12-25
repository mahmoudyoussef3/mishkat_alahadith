import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// A slightly animated checkbox that feels calm and spiritual.
class AnimatedCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const AnimatedCheckbox({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder:
          (child, animation) => ScaleTransition(scale: animation, child: child),
      child: Checkbox(
        key: ValueKey<bool>(value),
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: const BorderSide(color: ColorsManager.mediumGray, width: 2),
      ),
    );
  }
}
