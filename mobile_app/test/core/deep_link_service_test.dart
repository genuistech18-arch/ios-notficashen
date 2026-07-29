import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/deep_link_service.dart';

void main() {
  group('DeepLinkService.extractCode', () {
    test('parses a well-formed deep link', () {
      final uri = Uri.parse('myapp://open?code=1234');
      expect(DeepLinkService.extractCode(uri), '1234');
    });

    test('returns null for the wrong scheme', () {
      final uri = Uri.parse('https://example.com/open?code=1234');
      expect(DeepLinkService.extractCode(uri), isNull);
    });

    test('returns null when the code param is missing', () {
      final uri = Uri.parse('myapp://open');
      expect(DeepLinkService.extractCode(uri), isNull);
    });

    test('returns null when the code param is empty', () {
      final uri = Uri.parse('myapp://open?code=');
      expect(DeepLinkService.extractCode(uri), isNull);
    });
  });
}
