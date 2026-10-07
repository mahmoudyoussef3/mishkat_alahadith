import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_plurals.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/logic/hadith_reader_cubit.dart';

/// Bottom bar that steps to the previous and next hadith of the chapter.
class HadithReaderBar extends StatelessWidget {
  const HadithReaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HadithReaderCubit, HadithReaderState>(
      builder: (context, state) {
        final cubit = context.read<HadithReaderCubit>();
        final total = state.chapterTotal;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: ColorsManager.cardBackground,
            border: Border(top: BorderSide(color: ColorsManager.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
              child: Row(
                children: [
                  AppIconButton(
                    tooltip: 'الحديث السابق',
                    icon: Icons.chevron_left_rounded,
                    size: 46.r,
                    onPressed:
                        state.hasPrevious && !state.isLoading
                            ? cubit.previous
                            : null,
                  ),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child:
                          state.failed
                              ? TextButton.icon(
                                onPressed: cubit.retry,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('تعذر التحميل، أعد المحاولة'),
                              )
                              : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    toArabicDigits('الحديث ${state.hadithId}'),
                                    style: TextStyles.titleSmall.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 1.4,
                                    ),
                                  ),
                                  Text(
                                    state.isLoading
                                        ? 'جاري التحميل…'
                                        : total == null
                                        ? ''
                                        : '${arabicCount(total, ArabicNoun.hadith)} في الباب',
                                    style: TextStyles.labelSmall,
                                  ),
                                ],
                              ),
                    ),
                  ),
                  AppIconButton(
                    tooltip: 'الحديث التالي',
                    icon: Icons.chevron_right_rounded,
                    size: 46.r,
                    variant: AppIconButtonVariant.filled,
                    onPressed:
                        state.hasNext && !state.isLoading ? cubit.next : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
