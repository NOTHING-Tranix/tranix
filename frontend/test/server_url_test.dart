import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/core/providers.dart';

/// Testing builds: the server address typed on the Welcome screen.
void main() {
  test('server address accepts a host, a base URL or a full API URL', () {
    expect(normalizeServerUrl('kimber-feudalistic-quotidianly.ngrok-free.dev'),
        'https://kimber-feudalistic-quotidianly.ngrok-free.dev/api/v1');
    expect(normalizeServerUrl(' https://abc.ngrok-free.dev/ '), 'https://abc.ngrok-free.dev/api/v1');
    expect(normalizeServerUrl('http://10.0.2.2:8080/api/v1'), 'http://10.0.2.2:8080/api/v1');
    expect(normalizeServerUrl(''), isNull);
  });
}
