import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';

class DeepLinkRouter {
  static const String _apiHost = 'api.hadith-shareef.com';

  static Future<void> handle(Uri uri) async {
    final action = _parse(uri);
    if (action == null) {
      if (kDebugMode) debugPrint('Unhandled deep link: $uri');
      return;
    }

    await _waitForNavigator();

    switch (action) {
      case _OpenHadithById(:final id):
        navigatorKey.currentState?.pushNamed(
          Routes.deepLinkHadith,
          arguments: id,
        );
    }
  }

  static _DeepLinkAction? _parse(Uri uri) {
    // HTTPS: https://api.hadith-shareef.com/hadith/<id>
    if (uri.scheme == 'https' && uri.host == _apiHost) {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty && segments.first == 'hadith') {
        final id =
            segments.length >= 2 ? segments[1] : uri.queryParameters['id'];
        if (_isValidId(id)) return _OpenHadithById(id!);
      }
    }

    // Custom scheme: mishkat://hadith/<id>
    if (uri.scheme == 'mishkat') {
      if (uri.host == 'hadith') {
        final id =
            uri.pathSegments.isNotEmpty
                ? uri.pathSegments.first
                : uri.queryParameters['id'];
        if (_isValidId(id)) return _OpenHadithById(id!);
      }

      // Alternative: mishkat://api.hadith-shareef.com/hadith/<id>
      if (uri.host == _apiHost) {
        final segments = uri.pathSegments;
        if (segments.isNotEmpty && segments.first == 'hadith') {
          final id =
              segments.length >= 2 ? segments[1] : uri.queryParameters['id'];
          if (_isValidId(id)) return _OpenHadithById(id!);
        }
      }
    }

    return null;
  }

  static bool _isValidId(String? value) {
    if (value == null) return false;
    final v = value.trim();
    return v.isNotEmpty;
  }

  static Future<void> _waitForNavigator() async {
    const maxWait = Duration(seconds: 5);
    const step = Duration(milliseconds: 50);

    final start = DateTime.now();
    while (navigatorKey.currentState == null) {
      if (DateTime.now().difference(start) > maxWait) return;
      await Future<void>.delayed(step);
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

sealed class _DeepLinkAction {
  const _DeepLinkAction();
}

final class _OpenHadithById extends _DeepLinkAction {
  final String id;
  const _OpenHadithById(this.id);
}
