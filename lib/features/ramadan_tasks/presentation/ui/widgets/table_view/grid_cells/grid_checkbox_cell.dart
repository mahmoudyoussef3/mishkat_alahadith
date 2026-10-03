import 'package:flutter/material.dart';
import '../table_checkbox_cell.dart';

/// Stateless cell widget: shows a checkbox or an empty placeholder
/// depending on whether the task applies to the given day.
class GridCheckboxCell extends StatelessWidget {
  final bool isApplicable;
  final bool isCompleted;
  final VoidCallback? onToggle;

  const GridCheckboxCell({
    super.key,
    required this.isApplicable,
    required this.isCompleted,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (!isApplicable) return const TableEmptyCell();
    final isEnabled = onToggle != null;
    return TableCheckboxCell(
      isCompleted: isCompleted,
      enabled: isEnabled,
      onToggle: onToggle,
    );
  }
}
