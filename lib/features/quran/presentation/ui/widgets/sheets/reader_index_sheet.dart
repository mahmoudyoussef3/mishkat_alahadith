import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/hizb_index/quran_hizb_index_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_index/quran_index_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/common/quran_sheet.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/widgets/index/quran_index_view.dart';

/// A place to turn to, and what to recite from there if the reader asked to
/// listen.
typedef QuranTarget =
    ({int page, int? ayahId, int? surahNumber, RecitationRequest? recitation});

/// The surah, juz, hizb and bookmark index over the mushaf, with the surah
/// and juz being read marked. Resolves to the place the reader picked.
Future<QuranTarget?> showReaderIndexSheet(
  BuildContext context, {
  required int currentPage,
}) {
  return showQuranSheet<QuranTarget>(
    context: context,
    initialChildSize: 0.86,
    maxChildSize: 0.95,
    builder:
        (sheetContext, controller) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<QuranIndexCubit>()..load()),
            BlocProvider(create: (_) => getIt<QuranHizbIndexCubit>()),
          ],
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
                        subtitle: 'السور والأجزاء والأحزاب وعلاماتك المحفوظة',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            onOpenPage:
                (page, {ayahId, surahNumber}) =>
                    Navigator.of(sheetContext).pop((
                      page: page,
                      ayahId: ayahId,
                      surahNumber: surahNumber,
                      recitation: null,
                    )),
            onListen:
                (request, {required page, surahNumber}) =>
                    Navigator.of(sheetContext).pop((
                      page: page,
                      ayahId: null,
                      surahNumber: surahNumber,
                      recitation: request,
                    )),
          ),
        ),
  );
}
