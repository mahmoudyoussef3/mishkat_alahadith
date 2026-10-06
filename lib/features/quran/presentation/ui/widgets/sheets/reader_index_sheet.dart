import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_index/quran_index_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/index/quran_index_view.dart';

typedef QuranTarget = ({int page, int? ayahId});

/// The surah, juz and bookmark index over the mushaf, with the surah and juz
/// being read marked. Resolves to the place the reader picked.
Future<QuranTarget?> showReaderIndexSheet(
  BuildContext context, {
  required int currentPage,
}) {
  return showQuranSheet<QuranTarget>(
    context: context,
    initialChildSize: 0.86,
    maxChildSize: 0.95,
    builder:
        (sheetContext, controller) => BlocProvider(
          create: (_) => getIt<QuranIndexCubit>()..load(),
          child: QuranIndexView(
            controller: controller,
            currentPage: currentPage,
            leadingSlivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      QuranSheetHandle(),
                      QuranSheetHeader(
                        title: 'فهرس المصحف',
                        subtitle: 'السور والأجزاء وعلاماتك المحفوظة',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            onOpenPage:
                (page, {ayahId}) => Navigator.of(
                  sheetContext,
                ).pop((page: page, ayahId: ayahId)),
          ),
        ),
  );
}
