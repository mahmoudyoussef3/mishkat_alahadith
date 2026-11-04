import 'azkar_category.dart';
import 'zikr.dart';

enum AzkarPlaybackStatus { idle, loading, playing, paused, completed }

/// A recitation to listen to: a whole chapter, or one zikr in it.
class AzkarAudioTrack {
  final String audioFile;
  final int categoryId;

  /// Null for the recitation of the whole chapter.
  final int? zikrId;

  const AzkarAudioTrack({
    required this.audioFile,
    required this.categoryId,
    this.zikrId,
  });

  /// Null when the chapter has no recitation.
  static AzkarAudioTrack? ofCategory(AzkarCategory category) {
    final file = category.audioFile;
    if (file == null) return null;
    return AzkarAudioTrack(audioFile: file, categoryId: category.id);
  }

  /// Null when the zikr has no recitation.
  static AzkarAudioTrack? ofZikr(AzkarCategory category, Zikr zikr) {
    final file = zikr.audioFile;
    if (file == null) return null;
    return AzkarAudioTrack(
      audioFile: file,
      categoryId: category.id,
      zikrId: zikr.id,
    );
  }

  bool get isWholeCategory => zikrId == null;

  @override
  bool operator ==(Object other) =>
      other is AzkarAudioTrack &&
      other.audioFile == audioFile &&
      other.categoryId == categoryId &&
      other.zikrId == zikrId;

  @override
  int get hashCode => Object.hash(audioFile, categoryId, zikrId);
}
