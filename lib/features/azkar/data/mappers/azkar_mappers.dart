import '../../domain/entities/azkar_audio.dart';
import '../../domain/entities/azkar_category.dart';
import '../../domain/entities/azkar_day_progress.dart';
import '../../domain/entities/zikr.dart';
import '../models/azkar_audio_track_model.dart';
import '../models/azkar_category_model.dart';
import '../models/azkar_progress_model.dart';

/// The Arabic chapters, each with its translation from [translated] when one
/// is given. Chapters and azkar are paired by id, so a translation missing
/// an entry leaves only that entry untranslated.
List<AzkarCategory> mergeAzkarCatalog(
  List<AzkarCategoryModel> arabic,
  List<AzkarCategoryModel>? translated,
) {
  final translations = {
    for (final category in translated ?? const <AzkarCategoryModel>[])
      category.id: category,
  };
  return List.unmodifiable([
    for (final category in arabic)
      category.toEntity(translation: translations[category.id]),
  ]);
}

extension AzkarCategoryModelMapper on AzkarCategoryModel {
  AzkarCategory toEntity({AzkarCategoryModel? translation}) {
    final translatedAzkar = {
      for (final zikr in translation?.azkar ?? const <ZikrModel>[])
        zikr.id: zikr,
    };
    return AzkarCategory(
      id: id,
      title: title,
      translatedTitle: translation?.title,
      audioFile: audioFile,
      azkar: List.unmodifiable([
        for (final zikr in azkar)
          zikr.toEntity(translation: translatedAzkar[zikr.id]),
      ]),
    );
  }
}

extension ZikrModelMapper on ZikrModel {
  Zikr toEntity({ZikrModel? translation}) {
    // Where a translation is missing upstream, its file repeats the Arabic.
    final translatedText = translation?.text;
    return Zikr(
      id: id,
      text: text,
      count: count,
      audioFile: audioFile,
      translation: translatedText == text ? null : translatedText,
      transliteration: translation?.transliteration ?? transliteration,
    );
  }
}

extension AzkarProgressModelMapper on AzkarProgressModel {
  /// Null when the stored day cannot be read.
  AzkarDayProgress? toEntity() {
    final parsed = DateTime.tryParse(day);
    if (parsed == null) return null;
    return AzkarDayProgress(
      day: AzkarDayProgress.dayOf(parsed),
      counts: Map.unmodifiable({
        for (final MapEntry(key: categoryId, value: category) in counts.entries)
          categoryId: Map<int, int>.unmodifiable(category),
      }),
    );
  }
}

extension AzkarDayProgressMapper on AzkarDayProgress {
  AzkarProgressModel toModel() => AzkarProgressModel(
    day:
        '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}',
    counts: counts,
  );
}

extension AzkarAudioTrackModelMapper on AzkarAudioTrackModel {
  AzkarAudioTrack toEntity() => AzkarAudioTrack(
    audioFile: audioFile,
    categoryId: categoryId,
    zikrId: zikrId,
    categoryTitle: categoryTitle,
    zikrNumber: zikrNumber,
  );
}

extension AzkarAudioTrackMapper on AzkarAudioTrack {
  AzkarAudioTrackModel toModel() => AzkarAudioTrackModel(
    audioFile: audioFile,
    categoryId: categoryId,
    zikrId: zikrId,
    categoryTitle: categoryTitle,
    zikrNumber: zikrNumber,
  );
}
