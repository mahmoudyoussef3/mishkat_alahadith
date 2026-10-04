import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mishkat_almasabih/core/deep_links/hadith_link.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';

class DeepLinkRouter {
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
    final id = HadithLink.parseId(uri);
    return id == null ? null : _OpenHadithById(id);
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
