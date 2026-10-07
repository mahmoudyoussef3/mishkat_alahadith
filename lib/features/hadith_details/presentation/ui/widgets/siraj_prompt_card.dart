import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/hero_surface.dart';
import 'package:mishkat_almasabih/features/serag/presentation/ui/widgets/siraj_mark.dart';

/// Invitation to understand the hadith with Siraj, the AI assistant: a
/// quick structured analysis, or an open conversation.
class SirajPromptCard extends StatelessWidget {
  const SirajPromptCard({
    super.key,
    required this.onAnalyze,
    required this.onAsk,
  });

  final VoidCallback onAnalyze;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    final muted = ColorsManager.white.withValues(alpha: 0.78);

    return HeroSurface(
      showImage: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SirajMark(),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سراج · المساعد الذكي',
                      style: TextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                        color: ColorsManager.white,
                      ),
                    ),
                    Text(
                      'شرح مختصر، فوائد الحديث، ومعاني الكلمات',
                      style: TextStyles.caption.copyWith(
                        height: 1.6,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAnalyze,
                  style: FilledButton.styleFrom(
                    backgroundColor: ColorsManager.goldBright,
                    foregroundColor: ColorsManager.onGoldBright,
                    minimumSize: Size.fromHeight(46.h),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    textStyle: TextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  icon: Icon(Icons.bolt_rounded, size: 19.r),
                  label: const Text('تحليل سريع'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAsk,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: ColorsManager.white.withValues(alpha: 0.12),
                    foregroundColor: ColorsManager.white,
                    side: BorderSide(
                      color: ColorsManager.white.withValues(alpha: 0.22),
                    ),
                    minimumSize: Size.fromHeight(46.h),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    textStyle: TextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: Icon(Icons.chat_rounded, size: 19.r),
                  label: const Text('اسأل سراج'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
