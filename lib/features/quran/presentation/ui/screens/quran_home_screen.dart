import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/widgets/app_icon_button.dart';
import 'package:mishkat_almasabih/core/widgets/screen_title_header.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_index/quran_index_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/models/mushaf_reader_args.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/index/continue_reading_card.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/index/quran_index_view.dart';

/// The Quran's front door: resume reading, browse surahs and ajzāʾ, revisit
/// bookmarks, search, or study the tajweed rules.
class QuranHomeScreen extends StatelessWidget {
  const QuranHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.secondaryBackground,
        body: SafeArea(
          bottom: false,
          child: QuranIndexView(
            onOpenPage:
                (page, {ayahId, surahNumber}) => _openReader(
                  context,
                  page,
                  ayahId: ayahId,
                  surahNumber: surahNumber,
                ),
            leadingSlivers: [
              SliverToBoxAdapter(
                child: ScreenTitleHeader(
                  title: 'القرآن الكريم',
                  subtitle: 'مصحف المدينة · رواية حفص عن عاصم',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIconButton(
                        tooltip: 'البحث في الآيات',
                        icon: Icons.search_rounded,
                        onPressed:
                            () => _openAndRefresh(context, Routes.quranSearch),
                      ),
                      SizedBox(width: 8.w),
                      AppIconButton(
                        tooltip: 'دليل أحكام التجويد',
                        icon: Icons.school_rounded,
                        onPressed: () => context.pushNamed(Routes.tajweedGuide),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 4.h),
                sliver: SliverToBoxAdapter(
                  child: ContinueReadingCard(
                    onOpenPage: (page) => _openReader(context, page),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openReader(
    BuildContext context,
    int page, {
    int? ayahId,
    int? surahNumber,
  }) => _openAndRefresh(
    context,
    Routes.mushafReader,
    arguments: MushafReaderArgs(
      initialPage: page,
      highlightAyahId: ayahId,
      surahNumber: surahNumber,
    ),
  );

  /// Reading changes the last page and the bookmarks, so they are re-read on
  /// the way back.
  Future<void> _openAndRefresh(
    BuildContext context,
    String route, {
    Object? arguments,
  }) async {
    final cubit = context.read<QuranIndexCubit>();
    FocusManager.instance.primaryFocus?.unfocus();
    await context.pushNamed(route, arguments: arguments);
    await cubit.refreshReadingData();
  }
}
