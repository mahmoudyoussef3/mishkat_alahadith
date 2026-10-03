import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';

class DeepLinkRouter {
  static const String _apiHost = 'api.hadith-shareef.com';
  static const Set<String> _reservedSegments = {'api', 'hadith'};

  static String? extractHadithId(Uri uri) =>
      _extractHadithIdFromPathOrQuery(uri);

  static Future<void> handle(Uri uri) async {
    final action = _parse(uri);

    if (action == null) {
      if (kDebugMode) debugPrint('❌ Unhandled deep link: $uri');
      return;
    }

    await _waitForNavigator();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (action) {
        case _OpenHadithById(:final id):
          navigatorKey.currentState?.pushNamed(
            Routes.shareHadithLink,
            arguments: id,
          );
      }
    });
  }

  static _DeepLinkAction? _parse(Uri uri) {
    if (uri.scheme == 'https' && uri.host == _apiHost) {
      final id = _sanitizeId(extractHadithId(uri));
      if (_isValidId(id)) return _OpenHadithById(id!);
    }

    if (uri.scheme == 'mishkat') {
      if (uri.host == 'hadith' || uri.host == _apiHost) {
        final id = _sanitizeId(extractHadithId(uri));
        if (_isValidId(id)) return _OpenHadithById(id!);
      }
    }

    return null;
  }

  static String? _extractHadithIdFromPathOrQuery(Uri uri) {
    final fromQuery = uri.queryParameters['id'];
    if (_isValidId(fromQuery)) return fromQuery;

    final segments = uri.pathSegments
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (segments.isEmpty) return null;

    final hadithIndex = segments.indexOf('hadith');
    if (hadithIndex != -1 && hadithIndex + 1 < segments.length) {
      final next = segments[hadithIndex + 1];
      if (_isValidId(next)) return next;
    }

    for (final seg in segments.reversed) {
      if (_reservedSegments.contains(seg)) continue;
      if (_isValidId(seg)) return seg;
    }

    return null;
  }

  static bool _isValidId(String? value) {
    if (value == null) return false;
    final v = value.replaceAll('%C2%A0', '').replaceAll('\u00A0', '').trim();
    return v.isNotEmpty && !_reservedSegments.contains(v);
  }

  static String? _sanitizeId(String? value) {
    if (value == null) return null;
    final v = value.replaceAll('%C2%A0', '').replaceAll('\u00A0', '').trim();
    return v;
  }

  static Future<void> _waitForNavigator() async {
    const maxWait = Duration(seconds: 5);
    const step = Duration(milliseconds: 50);

    final start = DateTime.now();

    while (navigatorKey.currentState == null) {
      if (DateTime.now().difference(start) > maxWait) return;
      await Future.delayed(step);
    }

    await Future.delayed(const Duration(milliseconds: 50));
  }
}

sealed class _DeepLinkAction {
  const _DeepLinkAction();
}

final class _OpenHadithById extends _DeepLinkAction {
  final String id;
  const _OpenHadithById(this.id);
}
