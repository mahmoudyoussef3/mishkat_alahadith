import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/quran_decorations.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/build_header_app_bar.dart';
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
            colors: QuranSurfaceColors.app(),
            onOpenPage: (page, {ayahId}) => _openReader(context, page, ayahId),
            leadingSlivers: [
              BuildHeaderAppBar(
                title: 'القرآن الكريم',
                description: 'مصحف المدينة النبوية برواية حفص عن عاصم',
                pinned: true,
                actions: [
                  AppBarActionButton(
                    icon: Icons.search_rounded,
                    onPressed:
                        () => _openAndRefresh(context, Routes.quranSearch),
                  ),
                  AppBarActionButton(
                    icon: Icons.school_rounded,
                    onPressed: () => context.pushNamed(Routes.tajweedGuide),
                  ),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
                sliver: SliverToBoxAdapter(
                  child: ContinueReadingCard(
                    onOpenPage: (page) => _openReader(context, page, null),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openReader(BuildContext context, int page, int? ayahId) =>
      _openAndRefresh(
        context,
        Routes.mushafReader,
        arguments: MushafReaderArgs(initialPage: page, highlightAyahId: ayahId),
      );

  /// Reading changes the last page and the bookmarks, so they are re-read on
  /// the way back.
  Future<void> _openAndRefresh(
    BuildContext context,
    String route, {
    Object? arguments,
  }) async {
    final cubit = context.read<QuranIndexCubit>();
    await context.pushNamed(route, arguments: arguments);
    await cubit.refreshReadingData();
  }
}
