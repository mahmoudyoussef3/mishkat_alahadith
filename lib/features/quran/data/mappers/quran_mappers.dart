import 'package:mushaf_text/mushaf_text.dart';

import '../../domain/entities/quran_ayah.dart';
import '../../domain/entities/quran_bookmark.dart';
import '../../domain/entities/quran_surah.dart';
import '../../domain/entities/tajweed_info.dart';
import '../models/quran_bookmark_model.dart';

extension SurahMapper on Surah {
  QuranSurah toEntity() => QuranSurah(
    number: number,
    nameArabic: nameArabic,
    nameEnglish: nameEnglish,
    ayahCount: ayahCount,
    startPage: startPage,
    endPage: endPage,
  );
}

extension AyahMapper on Ayah {
  QuranAyah toEntity() => QuranAyah(
    id: id,
    surahNumber: surah,
    number: number,
    juz: juz,
    page: page,
    text: text,
  );
}

extension TajweedSpanMapper on TajweedSpan {
  TajweedSegment toEntity() =>
      TajweedSegment(start: start, end: end, ruleKey: rule.name);
}

extension TajweedCountMapper on MapEntry<TajweedRule, int> {
  TajweedRuleCount toEntity() =>
      TajweedRuleCount(ruleKey: key.name, count: value);
}

extension QuranBookmarkModelMapper on QuranBookmarkModel {
  QuranBookmark toEntity() => QuranBookmark(
    page: page,
    surahNumber: surahNumber,
    surahName: surahName,
    ayahId: ayahId,
    ayahNumber: ayahNumber,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
  );
}

extension QuranBookmarkMapper on QuranBookmark {
  QuranBookmarkModel toModel() => QuranBookmarkModel(
    page: page,
    surahNumber: surahNumber,
    surahName: surahName,
    ayahId: ayahId,
    ayahNumber: ayahNumber,
    createdAtMillis: createdAt.millisecondsSinceEpoch,
  );
}
