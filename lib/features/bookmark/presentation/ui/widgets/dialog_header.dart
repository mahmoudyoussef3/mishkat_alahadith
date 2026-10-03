import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_decorations.dart';
import 'package:mishkat_almasabih/core/theming/bookmark_styles.dart';

class DialogHeader extends StatelessWidget {
  final String title;
  const DialogHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BookmarkDecorations.iconCircleGradient(),
          child: const Icon(Icons.bookmark, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Text(title, style: BookmarkTextStyles.dialogTitle),
      ],
    );
  }
}
