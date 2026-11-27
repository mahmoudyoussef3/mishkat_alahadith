import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_hizb_quarter.dart';
import '../entities/quran_metrics.dart';
import '../repos/quran_cloud_repo.dart';
import '../repos/quran_repo.dart';

/// The 240 quarters of the ahzāb, each placed on its page of the bundled
/// mushaf: where they begin comes from the service, everything else from
/// the mushaf itself.
class GetHizbIndexUseCase {
  final QuranCloudRepo _cloud;
  final QuranRepo _quran;

  GetHizbIndexUseCase(this._cloud, this._quran);

  Future<ApiResult<List<QuranHizbQuarter>>> call() async {
    final (startsResult, ayahsResult, surahsResult) =
        await (
          _cloud.getHizbQuarterStarts(),
          _quran.getAllAyahs(),
          _quran.getSurahs(),
        ).wait;

    switch ((startsResult, ayahsResult, surahsResult)) {
      case (ApiFailure(:final failure), _, _):
      case (_, ApiFailure(:final failure), _):
      case (_, _, ApiFailure(:final failure)):
        return ApiResult.failure(failure);
      case (
        ApiSuccess(data: final starts),
        ApiSuccess(data: final ayahs),
        ApiSuccess(data: final surahs),
      ):
        if (starts.length != QuranMetrics.hizbQuarterCount) {
          return const ApiResult.failure(UnexpectedFailure());
        }
        final byRef = {
          for (final ayah in ayahs) (ayah.surahNumber, ayah.number): ayah,
        };
        final surahNames = {for (final s in surahs) s.number: s.nameArabic};
        final quarters = <QuranHizbQuarter>[];
        for (var i = 0; i < starts.length; i++) {
          final ref = starts[i];
          final ayah = byRef[(ref.surah, ref.ayah)];
          // Every quarter must land on an ayah, in order, or the index lies.
          if (ayah == null ||
              (quarters.isNotEmpty && quarters.last.startAyahId >= ayah.id)) {
            return const ApiResult.failure(UnexpectedFailure());
          }
          quarters.add(
            QuranHizbQuarter(
              number: i + 1,
              startAyahId: ayah.id,
              surahNumber: ayah.surahNumber,
              surahName: surahNames[ayah.surahNumber] ?? '',
              ayahNumber: ayah.number,
              page: ayah.page,
            ),
          );
        }
        return ApiResult.success(List.unmodifiable(quarters));
    }
  }
}
