/// A recitation of the azkar as kept on the device.
class AzkarAudioTrackModel {
  final String audioFile;
  final int categoryId;
  final int? zikrId;
  final String categoryTitle;
  final int? zikrNumber;

  const AzkarAudioTrackModel({
    required this.audioFile,
    required this.categoryId,
    required this.categoryTitle,
    this.zikrId,
    this.zikrNumber,
  });

  /// Null when the stored entry is missing the file or the chapter: there
  /// is then nothing to offer again.
  static AzkarAudioTrackModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    if (json case {
      'audioFile': final String audioFile,
      'categoryId': final int categoryId,
    }) {
      final zikrId = json['zikrId'];
      final categoryTitle = json['categoryTitle'];
      final zikrNumber = json['zikrNumber'];
      return AzkarAudioTrackModel(
        audioFile: audioFile,
        categoryId: categoryId,
        zikrId: zikrId is int ? zikrId : null,
        categoryTitle: categoryTitle is String ? categoryTitle : '',
        zikrNumber: zikrNumber is int ? zikrNumber : null,
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'audioFile': audioFile,
    'categoryId': categoryId,
    'categoryTitle': categoryTitle,
    if (zikrId != null) 'zikrId': zikrId,
    if (zikrNumber != null) 'zikrNumber': zikrNumber,
  };
}
