/// The public hadith link: built when a hadith is shared, read back when the
/// OS opens the app with one.
abstract final class HadithLink {
  // Must match the host in AndroidManifest.xml, Runner.entitlements and the
  // server's assetlinks.json / apple-app-site-association files.
  static const String host = 'api.hadith-shareef.com';
  static const String _appScheme = 'mishkat';
  static const String _hadithSegment = 'hadith';
  static const Set<String> _reservedSegments = {'api', _hadithSegment};
  static final RegExp _validId = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

  /// The link shared for [hadithId], or null when [parseId] could not read the
  /// id back on the receiving device.
  static Uri? build(String hadithId) {
    final id = hadithId.trim();
    if (!_isValidId(id)) return null;
    return Uri(
      scheme: 'https',
      host: host,
      pathSegments: ['api', _hadithSegment, id],
    );
  }

  /// Returns the hadith id of a link this app owns, or null for any other
  /// link or for an id that is not a plain identifier.
  static String? parseId(Uri uri) {
    final isWebLink = uri.scheme == 'https' && uri.host == host;
    final isAppLink =
        uri.scheme == _appScheme &&
        (uri.host == _hadithSegment || uri.host == host);
    if (!isWebLink && !isAppLink) return null;

    try {
      final fromQuery = uri.queryParameters['id']?.trim();
      if (_isValidId(fromQuery)) return fromQuery;

      final fromPath = _idFromPath(uri)?.trim();
      return _isValidId(fromPath) ? fromPath : null;
    } on FormatException {
      // Percent-encoding that is not valid UTF-8.
      return null;
    }
  }

  static String? _idFromPath(Uri uri) {
    final segments =
        uri.pathSegments.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    // …/hadith/<id>
    final hadithIndex = segments.indexOf(_hadithSegment);
    if (hadithIndex != -1 && hadithIndex + 1 < segments.length) {
      return segments[hadithIndex + 1];
    }

    // mishkat://hadith/<id>
    if (uri.host == _hadithSegment) {
      return segments.lastWhere(
        (s) => !_reservedSegments.contains(s),
        orElse: () => '',
      );
    }

    return null;
  }

  static bool _isValidId(String? value) =>
      value != null &&
      !_reservedSegments.contains(value) &&
      _validId.hasMatch(value);
}
