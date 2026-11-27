import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_home_actions.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/helpers/azkar_ui_helpers.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/common/azkar_progress_badge.dart';

/// The chapters said every day, four to a row, each ringed with today's
/// progress.
class AzkarDailyGrid extends StatelessWidget {
  const AzkarDailyGrid({super.key});

  static const int _perRow = 4;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarHomeCubit, AzkarHomeState>(
      buildWhen:
          (previous, current) =>
              previous is! AzkarHomeLoaded ||
              current is! AzkarHomeLoaded ||
              previous.progress != current.progress,
      builder: (context, state) {
        if (state is! AzkarHomeLoaded) return const SizedBox.shrink();
        final tiles = [
          for (final (index, shortcut) in kDailyAzkarShortcuts.indexed)
            if (state.categoryById(shortcut.categoryId) case final category?)
              _DailyTile(
                shortcut: shortcut,
                progress: state.progressOf(category),
                tint: index % 3,
              ),
        ];
        return Column(
          children: [
            for (var start = 0; start < tiles.length; start += _perRow)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = start; i < start + _perRow; i++)
                      Expanded(
                        child: i < tiles.length ? tiles[i] : const SizedBox(),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DailyTile extends StatelessWidget {
  const _DailyTile({
    required this.shortcut,
    required this.progress,
    required this.tint,
  });

  final AzkarShortcut shortcut;
  final AzkarCategoryProgress progress;

  /// Which of the three accent pairs to draw in.
  final int tint;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tint) {
      0 => (ColorsManager.goldSoft, ColorsManager.goldInk),
      1 => (ColorsManager.primarySoft, ColorsManager.purpleText),
      _ => (ColorsManager.successSoft, ColorsManager.success),
    };
    return Semantics(
      button: true,
      label: shortcut.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => openAzkarReader(context, categoryId: shortcut.categoryId),
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
          child: Column(
            children: [
              AzkarProgressBadge(
                progress: progress,
                icon: shortcut.icon,
                size: 60.r,
                background: background,
                foreground: foreground,
              ),
              SizedBox(height: 6.h),
              Text(
                shortcut.label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.chipLabel.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
