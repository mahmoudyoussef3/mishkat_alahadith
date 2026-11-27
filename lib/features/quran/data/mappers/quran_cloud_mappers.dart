import '../../domain/entities/quran_commentary.dart';
import '../../domain/entities/quran_edition.dart';
import '../../domain/entities/quran_metrics.dart';
import '../../domain/entities/recitation.dart';
import '../../domain/entities/recitation_settings.dart';
import '../models/quran_cloud_models.dart';

extension QuranEditionModelMapper on QuranEditionModel {
  /// Null for kinds of edition the app has no use for — the Quran's text
  /// in other scripts, transliterations — and for unusable identifiers.
  QuranEdition? toEntity() {
    final kind = switch ((format, type)) {
      ('audio', _) => QuranEditionType.recitation,
      (_, 'tafsir') => QuranEditionType.tafsir,
      (_, 'translation') => QuranEditionType.translation,
      _ => null,
    };
    if (kind == null || !RecitationSettings.isValidEditionId(identifier)) {
      return null;
    }
    final displayName = name.trim().isEmpty ? englishName : name;
    return QuranEdition(
      identifier: identifier,
      name: language == 'ar' ? _arabicSpelling(displayName) : displayName,
      englishName: englishName,
      language: language,
      type: kind,
      isRightToLeft: switch (direction) {
        'rtl' => true,
        'ltr' => false,
        _ => _rightToLeftLanguages.contains(language),
      },
    );
  }

  static const Set<String> _rightToLeftLanguages = {
    'ar', 'fa', 'ur', 'ps', 'sd', 'ug', 'dv', 'ku', //
  };

  /// The service writes some Arabic names with the Persian yeh and keheh
  /// («تفسير المیسر»), which Arabic fonts draw differently.
  static String _arabicSpelling(String text) =>
      text.replaceAll('ی', 'ي').replaceAll('ک', 'ك').trim();
}

extension CloudAyahModelMapper on CloudAyahModel {
  /// Null without a secure audio address, or outside the mushaf.
  RecitationAudio? toRecitationAudio() {
    final url = audio;
    if (url == null ||
        !_isSecureUrl(url) ||
        !QuranMetrics.isValidAyahId(number)) {
      return null;
    }
    return RecitationAudio(
      ayahId: number,
      url: url,
      lowBitrateUrls: [
        for (final secondary in audioSecondary)
          if (_isSecureUrl(secondary)) secondary,
      ],
    );
  }

  /// This ayah's passage in its own edition, or in [parent] when it is
  /// nested in a surah that names it. Null without text or a usable edition.
  AyahEditionText? toEditionText({QuranEditionModel? parent}) {
    final edition = (this.edition ?? parent)?.toEntity();
    final passage = text.trim();
    if (edition == null ||
        passage.isEmpty ||
        !QuranMetrics.isValidAyahId(number)) {
      return null;
    }
    return AyahEditionText(
      ayahId: number,
      text: EditionText(edition: edition, text: passage),
    );
  }

  static bool _isSecureUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }
}
