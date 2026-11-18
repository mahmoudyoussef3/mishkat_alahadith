import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';

import 'azkar_category.dart';
import 'zikr.dart';

enum AzkarPlaybackStatus { idle, loading, playing, paused, completed }

/// A recitation to listen to: a whole chapter, or one zikr in it.
class AzkarAudioTrack {
  final String audioFile;
  final int categoryId;

  /// Null for the recitation of the whole chapter.
  final int? zikrId;

  /// The chapter's title, to name the recitation wherever it plays; empty
  /// when not known.
  final String categoryTitle;

  /// The zikr's place in its chapter, from 1; null for the whole chapter.
  final int? zikrNumber;

  const AzkarAudioTrack({
    required this.audioFile,
    required this.categoryId,
    this.zikrId,
    this.categoryTitle = '',
    this.zikrNumber,
  });

  /// Null when the chapter has no recitation.
  static AzkarAudioTrack? ofCategory(AzkarCategory category) {
    final file = category.audioFile;
    if (file == null) return null;
    return AzkarAudioTrack(
      audioFile: file,
      categoryId: category.id,
      categoryTitle: category.title,
    );
  }

  /// Null when the zikr has no recitation.
  static AzkarAudioTrack? ofZikr(AzkarCategory category, Zikr zikr) {
    final file = zikr.audioFile;
    if (file == null) return null;
    final index = category.azkar.indexWhere((z) => z.id == zikr.id);
    return AzkarAudioTrack(
      audioFile: file,
      categoryId: category.id,
      zikrId: zikr.id,
      categoryTitle: category.title,
      zikrNumber: index < 0 ? null : index + 1,
    );
  }

  bool get isWholeCategory => zikrId == null;

  /// «تلاوة الباب كاملاً», or «الذكر ٣».
  String get label {
    if (isWholeCategory) return 'تلاوة الباب كاملاً';
    final number = zikrNumber;
    return number == null ? 'الذكر' : 'الذكر ${toArabicDigits('$number')}';
  }

  /// «الذكر ٣ · أذكار الصباح والمساء»: the recitation as the player names
  /// it, in the app and outside it.
  String get title => categoryTitle.isEmpty ? label : '$label · $categoryTitle';

  /// The same recitation, whatever it is named.
  @override
  bool operator ==(Object other) =>
      other is AzkarAudioTrack &&
      other.audioFile == audioFile &&
      other.categoryId == categoryId &&
      other.zikrId == zikrId;

  @override
  int get hashCode => Object.hash(audioFile, categoryId, zikrId);
}
