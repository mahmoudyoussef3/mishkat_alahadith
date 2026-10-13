import 'package:mishkat_almasabih/core/helpers/arabic_digits.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_track.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_voice.dart';

extension SpeechPartLabel on SpeechPart {
  String get label => switch (this) {
    SpeechPart.heading => 'بيانات الحديث',
    SpeechPart.isnad => 'السند',
    SpeechPart.matn => 'متن الحديث',
    SpeechPart.source => 'التخريج',
    SpeechPart.explanation => 'الشرح',
    SpeechPart.lesson => 'الفوائد',
    SpeechPart.wordMeaning => 'معاني الكلمات',
  };
}

extension SpeechPartGapLabel on SpeechPartGap {
  String get label => switch (this) {
    SpeechPartGap.none => 'بدون',
    SpeechPartGap.short => 'قصير',
    SpeechPartGap.medium => 'متوسط',
    SpeechPartGap.long => 'طويل',
  };
}

/// «١٫٢٥×» for 1.25.
String speechRateLabel(double rate) {
  final fixed = rate.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  return '${toArabicDigits(fixed).replaceAll('.', '٫')}×';
}

extension SpeechVoiceLabels on SpeechVoice {
  /// Android names voices by id («ar-xa-x-arc-local»); those are shown by
  /// [position] instead. iOS names («Majed») are kept.
  String displayName(int position) {
    final looksLikeId =
        name.contains('-x-') ||
        name.contains('#') ||
        SpeechVoice.sameLocale(name, locale) ||
        RegExp(r'^[a-z]{2,3}[-_][a-z]{2}', caseSensitive: false).hasMatch(name);
    return looksLikeId ? 'الصوت ${toArabicDigits('$position')}' : name;
  }

  String get regionLabel {
    final parts = SpeechVoice.normalizeLocale(locale).split('-');
    final region = parts.length > 1 ? parts[1] : '';
    return switch (region) {
      '001' || 'xa' || '' => 'العربية الفصحى',
      'sa' => 'السعودية',
      'eg' => 'مصر',
      'ae' => 'الإمارات',
      'kw' => 'الكويت',
      'qa' => 'قطر',
      'bh' => 'البحرين',
      'om' => 'عُمان',
      'jo' => 'الأردن',
      'lb' => 'لبنان',
      'sy' => 'سوريا',
      'iq' => 'العراق',
      'ye' => 'اليمن',
      'ps' => 'فلسطين',
      'ma' => 'المغرب',
      'dz' => 'الجزائر',
      'tn' => 'تونس',
      'ly' => 'ليبيا',
      'sd' => 'السودان',
      _ => locale,
    };
  }

  String? get qualityLabel => switch (quality) {
    SpeechVoiceQuality.veryHigh => 'جودة فائقة',
    SpeechVoiceQuality.high => 'جودة عالية',
    SpeechVoiceQuality.normal => 'جودة عادية',
    SpeechVoiceQuality.low || SpeechVoiceQuality.veryLow => 'جودة منخفضة',
    SpeechVoiceQuality.unknown => null,
  };

  String? get genderLabel => switch (gender) {
    SpeechVoiceGender.male => 'صوت رجل',
    SpeechVoiceGender.female => 'صوت امرأة',
    SpeechVoiceGender.unspecified => null,
  };

  /// «السعودية · جودة عالية · يعمل دون إنترنت».
  String get details => [
    regionLabel,
    if (genderLabel case final gender?) gender,
    if (qualityLabel case final quality?) quality,
    if (!installed)
      'غير مثبّت على الجهاز'
    else if (requiresNetwork)
      'يحتاج إلى إنترنت'
    else
      'يعمل دون إنترنت',
  ].join(' · ');
}

/// A readable name for an Android speech engine package.
String speechEngineLabel(String engine) => switch (engine) {
  'com.google.android.tts' => 'محرك Google',
  'com.samsung.SMT' => 'محرك Samsung',
  'com.huawei.hiai' || 'com.huawei.tts' => 'محرك Huawei',
  'com.svox.pico' => 'Pico TTS',
  'com.reecedunn.espeak' || 'com.googlecode.eyesfree.espeak' => 'eSpeak',
  'es.codefactory.eloquencetts' => 'Eloquence',
  'com.github.olga_yakovleva.rhvoice.android' => 'RHVoice',
  _ => engine.split('.').last,
};
