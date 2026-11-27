import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/hadith_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_by_category/ahadith_by_category_cubit.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/logic/hadith_by_category/ahadith_by_category_state.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/presentation/ui/category_style.dart';

/// "أحاديث مشابهة": a few other hadiths of [category] to read next, in a
/// horizontal strip. Hidden while loading or when there are none.
class SimilarAhadithSection extends StatefulWidget {
  const SimilarAhadithSection({
    super.key,
    required this.category,
    required this.onOpen,
    this.excludeId,
    this.busy = false,
  });

  final CategoryEntity category;

  /// The hadith already on screen, left out of the strip.
  final String? excludeId;
  final ValueChanged<HadithEntity> onOpen;

  /// True while a tapped hadith is being opened; further taps wait.
  final bool busy;

  @override
  State<SimilarAhadithSection> createState() => _SimilarAhadithSectionState();
}

class _SimilarAhadithSectionState extends State<SimilarAhadithSection> {
  late final HadithByCategoryCubit _cubit =
      getIt<HadithByCategoryCubit>()..getAhadithByCategory(widget.category.id);

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HadithByCategoryCubit, HadithByCategoryState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is! HadithByCategoryLoaded) return const SizedBox.shrink();
        final ahadith =
            state.ahadith.where((h) => h.id != widget.excludeId).take(6).toList();
        if (ahadith.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    'أحاديث مشابهة في «${widget.category.title}»',
                    style: TextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (widget.busy)
                  SizedBox.square(
                    dimension: 16.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                TextButton(
                  onPressed:
                      () => Navigator.of(context).pushNamed(
                        Routes.ahadithListScreen,
                        arguments: CategoryHadithsArgs(
                          categoryId: widget.category.id,
                          title: widget.category.title,
                          hadithsCount: state.meta.totalItems,
                        ),
                      ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    minimumSize: Size(0, 32.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('عرض الكل', style: TextStyles.actionLabel),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 96.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ahadith.length,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder:
                    (context, index) => _SimilarCard(
                      hadith: ahadith[index],
                      onTap:
                          widget.busy ? null : () => widget.onOpen(ahadith[index]),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SimilarCard extends StatelessWidget {
  const _SimilarCard({required this.hadith, required this.onTap});

  final HadithEntity hadith;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230.w,
      child: Material(
        color: ColorsManager.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
          side: BorderSide(color: ColorsManager.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                hadith.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.readingMedium.copyWith(
                  fontSize: 16.sp,
                  height: 1.85,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
