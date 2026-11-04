import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/hero_surface.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_reader/azkar_reader_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';

/// The chapter's title above its azkar, with a way to start it over once
/// begun.
class AzkarChapterIntro extends StatelessWidget {
  const AzkarChapterIntro({super.key, required this.category});

  final AzkarCategory category;

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteOverride.of(context);
    final translatedTitle = category.translatedTitle;
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              category.title,
              style: TextStyles.screenTitle.copyWith(fontSize: 22.sp),
            ),
          ),
          if (translatedTitle != null)
            Text(
              translatedTitle,
              textDirection: TextDirection.ltr,
              style: TextStyles.caption.copyWith(fontSize: 13.sp),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$kHisnAlMuslim · '
                  '${arabicCount(category.azkar.length, ArabicNoun.zikr)}',
                  style: TextStyles.caption.copyWith(
                    fontSize: 13.sp,
                    color: palette.secondaryText,
                  ),
                ),
              ),
              BlocSelector<AzkarReaderCubit, AzkarReaderState, bool>(
                selector:
                    (state) =>
                        state is AzkarReaderLoaded && state.progress.isStarted,
                builder:
                    (context, started) =>
                        started
                            ? TextButton.icon(
                              onPressed:
                                  context.read<AzkarReaderCubit>().resetAll,
                              icon: Icon(Icons.restart_alt_rounded, size: 18.r),
                              label: Text(
                                'البدء من جديد',
                                style: TextStyles.actionLabel,
                              ),
                            )
                            : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shown under the last zikr once every zikr in the chapter is done.
class AzkarCompletionCard extends StatelessWidget {
  const AzkarCompletionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AzkarReaderCubit, AzkarReaderState, bool>(
      selector:
          (state) => state is AzkarReaderLoaded && state.progress.isComplete,
      builder:
          (context, complete) => AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child:
                complete ? const _CompletionContent() : const SizedBox.shrink(),
          ),
    );
  }
}

class _CompletionContent extends StatelessWidget {
  const _CompletionContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: HeroSurface(
        radius: 24.r,
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            Icon(
              Icons.verified_rounded,
              size: 40.r,
              color: ColorsManager.goldBright,
            ),
            SizedBox(height: 8.h),
            Text(
              'أتممت أذكار هذا الباب',
              textAlign: TextAlign.center,
              style: TextStyles.sectionTitle.copyWith(
                color: ColorsManager.white,
              ),
            ),
            Text(
              'تقبّل الله منك، وجعلها في ميزان حسناتك.',
              textAlign: TextAlign.center,
              style: TextStyles.caption.copyWith(
                fontSize: 13.sp,
                color: ColorsManager.white.withValues(alpha: 0.78),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: ColorsManager.goldBright,
                      foregroundColor: ColorsManager.onGoldBright,
                    ),
                    onPressed: context.read<AzkarReaderCubit>().resetAll,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('البدء من جديد'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorsManager.white,
                      side: BorderSide(
                        color: ColorsManager.white.withValues(alpha: 0.4),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('رجوع'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
