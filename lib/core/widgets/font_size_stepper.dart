import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/segmented_tabs.dart';

/// A choice of text sizes, smallest first, between buttons that step one
/// size down or up.
class FontSizeStepper extends StatelessWidget {
  const FontSizeStepper({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIconButton(
          tooltip: 'تصغير الخط',
          icon: Icons.text_decrease_rounded,
          onPressed:
              selectedIndex > 0 ? () => onChanged(selectedIndex - 1) : null,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: SegmentedTabs(
            labels: labels,
            selectedIndex: selectedIndex,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 8.w),
        AppIconButton(
          tooltip: 'تكبير الخط',
          icon: Icons.text_increase_rounded,
          onPressed:
              selectedIndex < labels.length - 1
                  ? () => onChanged(selectedIndex + 1)
                  : null,
        ),
      ],
    );
  }
}
