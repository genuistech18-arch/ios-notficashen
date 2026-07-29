import 'package:app_links/app_links.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  /// Cold-start deep link (app launched fresh via the link). Must be awaited
  /// before the first frame is built, otherwise it can be silently missed.
  Future<Uri?> getInitialLink() => _appLinks.getInitialLink();

  /// Warm/background deep links: app was already running (foreground or
  /// background) when the link was opened.
  Stream<Uri> get linkStream => _appLinks.uriLinkStream;

  /// Parses `myapp://open?code=1234` -> `"1234"`. Returns null for any
  /// malformed link (wrong scheme, missing/empty code param).
  static String? extractCode(Uri uri) {
    if (uri.scheme != 'myapp') return null;
    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) return null;
    return code;
  }
}
