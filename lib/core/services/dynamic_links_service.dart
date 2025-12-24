import 'dart:developer';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';

class DynamicLinksService {
  /// Initialize dynamic links handlers for app start and foreground links
  static Future<void> init() async {
    // No-op: deep links are delivered via platform channel (MainActivity.kt)
    return;
  }

  /// Build and return a short dynamic link for a hadith with query params
  static Future<Uri> buildHadithLink({
    required String hadithNumber,
    required String bookSlug,
    required bool isLocal,
    String? hadithText,
    String? narrator,
    String? grade,
    String? bookName,
    String? author,
    String? chapter,
    String? authorDeath,
  }) async {
    final Uri deepLink = Uri(
      scheme: 'mishkat',
      host: 'hadith',
      path: '/hadith',
      queryParameters: {
        'hadithNumber': hadithNumber,
        'bookSlug': bookSlug,
        'isLocal': isLocal.toString(),
        if (hadithText != null) 'hadithText': hadithText,
        if (narrator != null) 'narrator': narrator,
        if (grade != null) 'grade': grade,
        if (bookName != null) 'bookName': bookName,
        if (author != null) 'author': author,
        if (chapter != null) 'chapter': chapter,
        if (authorDeath != null) 'authorDeath': authorDeath,
      },
    );

    return deepLink;
  }

  /// Public entry to handle a deep-link string coming from platform channel
  static void handleLinkString(String linkStr) {
    try {
      final uri = Uri.parse(linkStr);
      _handleLink(uri);
    } catch (e) {
      log('handleLinkString parse error: $e');
    }
  }

  static void _handleLink(Uri link) {
    try {
      if (link.path == '/hadith') {
        final qp = link.queryParameters;
        final args = {
          'hadithText': qp['hadithText'],
          'chapterNumber': qp['chapter'] ?? '',
          'narrator': qp['narrator'],
          'grade': qp['grade'],
          'bookName': qp['bookName'],
          'author': qp['author'],
          'chapter': qp['chapter'],
          'authorDeath': qp['authorDeath'],
          'hadithNumber': qp['hadithNumber'],
          'bookSlug': qp['bookSlug'],
          'isLocal': (qp['isLocal'] ?? 'false') == 'true',
        };

        navigatorKey.currentState?.pushNamed(
          Routes.hadithDetail,
          arguments: args,
        );
      }
    } catch (e) {
      log('DynamicLinks handleLink error: $e');
    }
  }
}
