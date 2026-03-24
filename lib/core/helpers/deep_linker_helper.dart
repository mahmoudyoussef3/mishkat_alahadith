import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

/// Handles deep links from both cold start (terminated) and runtime (stream).
class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _sub;
  Uri? _lastHandled;

  Future<void> init(Future<void> Function(Uri uri) onLinkReceived) async {
    // 1) Cold start (terminated) deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleOnce(initialUri, onLinkReceived);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    // 2) Foreground/background deep link stream
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleOnce(uri, onLinkReceived);
      },
      onError: (err) {
        debugPrint('Failed to parse the link: $err');
      },
    );
  }

  Future<void> _handleOnce(
    Uri uri,
    Future<void> Function(Uri uri) onLinkReceived,
  ) async {
    // Some platforms can deliver the same URI multiple times (initial + stream).
    if (_lastHandled?.toString() == uri.toString()) return;
    _lastHandled = uri;

    try {
      await onLinkReceived(uri);
    } catch (e) {
      debugPrint('Deep link handler callback failed: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
