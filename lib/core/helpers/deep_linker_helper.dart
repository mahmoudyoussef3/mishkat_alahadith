import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class DeepLinkHandler {
  /// [linkStream] defaults to app_links' stream, which emits the link that
  /// launched the app followed by every link received while it runs. Reading
  /// `getInitialLink()` as well would deliver the launch link twice.
  ///
  /// [onError] receives failures to open a link; it defaults to a non-fatal
  /// Crashlytics report.
  DeepLinkHandler({
    Stream<Uri>? linkStream,
    void Function(Object error, StackTrace stack)? onError,
  }) : _linkStream = linkStream,
       _onError = onError ?? _recordNonFatal;

  final Stream<Uri>? _linkStream;
  final void Function(Object error, StackTrace stack) _onError;

  StreamSubscription<Uri>? _sub;

  void init(Future<void> Function(Uri uri) onLinkReceived) {
    if (_sub != null) return;
    _sub = (_linkStream ?? AppLinks().uriLinkStream).listen(
      (uri) => _handle(uri, onLinkReceived),
      onError: (Object error, StackTrace stack) => _onError(error, stack),
    );
  }

  Future<void> _handle(
    Uri uri,
    Future<void> Function(Uri uri) onLinkReceived,
  ) async {
    try {
      await onLinkReceived(uri);
    } catch (error, stack) {
      _onError(error, stack);
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  static void _recordNonFatal(Object error, StackTrace stack) {
    if (kDebugMode) debugPrint('Deep link failed: $error');
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: 'Opening a deep link failed',
      fatal: false,
    );
  }
}
