import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/core/widgets/filter_pill.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/logic/cubit/ahadiths_cubit.dart';

/// Pills that narrow a chapter to one grade, and a toggle that hides the
/// chains of narrators. Only the choices this chapter can use are shown;
/// with none, the bar is empty.
class ChapterFiltersBar extends StatelessWidget {
  const ChapterFiltersBar({
    super.key,
    required this.matnOnly,
    required this.onMatnOnlyChanged,
  });

  final bool matnOnly;
  final ValueChanged<bool> onMatnOnlyChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AhadithsCubit, AhadithsState>(
      buildWhen:
          (previous, current) =>
              _signature(previous) != _signature(current),
      builder: (context, state) {
        final (texts, grades, total, selected) = switch (state) {
          AhadithsSuccess(:final allAhadith, :final totalCount, :final gradeFilter) => (
            allAhadith.map((h) => h.hadithArabic ?? ''),
            {
              for (final h in allAhadith)
                if (HadithGrade.tryParse(h.status) case final grade?) grade,
            },
            totalCount ?? allAhadith.length,
            gradeFilter,
          ),
          LocalAhadithsSuccess(:final hadiths) => (
            hadiths.map((h) => h.arabic ?? ''),
            const <HadithGrade>{},
            hadiths.length,
            null,
          ),
          _ => (const <String>[], const <HadithGrade>{}, 0, null),
        };
        final hasIsnad = texts.any(
          (text) => HadithTextParts.split(text).isnad != null,
        );
        final showGrades = grades.length > 1;
        if (!showGrades && !hasIsnad) return const SizedBox.shrink();

        final cubit = context.read<AhadithsCubit>();
        return SizedBox(
          height: 38.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              FilterPill(
                label: toArabicDigits('الكل · $total'),
                selected: selected == null,
                onTap: () => cubit.filterByGrade(null),
              ),
              if (showGrades)
                for (final grade in HadithGrade.values.where(grades.contains))
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 6.w),
                    child: FilterPill(
                      label: grade.arabicLabel,
                      selected: selected == grade,
                      onTap:
                          () => cubit.filterByGrade(
                            selected == grade ? null : grade,
                          ),
                    ),
                  ),
              if (hasIsnad)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 6.w),
                  child: FilterPill(
                    label: 'المتن فقط',
                    selected: matnOnly,
                    onTap: () => onMatnOnlyChanged(!matnOnly),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// What the bar depends on: the loaded hadiths and the grade selection.
  static Object? _signature(AhadithsState state) => switch (state) {
    AhadithsSuccess(:final allAhadith, :final gradeFilter, :final totalCount) =>
      (allAhadith.length, gradeFilter, totalCount),
    LocalAhadithsSuccess(:final hadiths) => hadiths.length,
    _ => null,
  };
}
