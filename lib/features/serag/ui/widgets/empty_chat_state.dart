import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/serag_decorations.dart';
import 'package:mishkat_almasabih/core/theming/serag_styles.dart';

class EmptyChatState extends StatelessWidget {
  const EmptyChatState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: SeragDecorations.emptyStateIconSize,
              color: SeragDecorations.emptyStateIconColor,
            ),
            SizedBox(height: 16.h),
            Text(
              "ابدأ بكتابة سؤالك لبدء المحادثة",
              style: SeragTextStyles.emptyStateMainText,
            ),
            SizedBox(height: 8.h),
            Text(
              "سراج مساعدك الذكي للإجابة على أسئلة الحديث",
              textAlign: TextAlign.center,
              style: SeragTextStyles.emptyStateSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
