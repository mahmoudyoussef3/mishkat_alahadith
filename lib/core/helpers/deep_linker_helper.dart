import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _sub;
  Uri? _lastHandled;

  Future<void> init(Future<void> Function(Uri uri) onLinkReceived) async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleOnce(initialUri, onLinkReceived);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

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
