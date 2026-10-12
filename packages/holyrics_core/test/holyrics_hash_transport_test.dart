import 'package:holyrics_core/holyrics_core.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('HolyricsHashTransport', () {
    test('authenticates once then increments rid per request', () async {
      final calls = <Uri>[];
      final client = HolyricsClient.local(
        host: 'h',
        port: 1,
        token: 'abcdef',
        httpClient: MockClient((request) async {
          calls.add(request.url);
          if (request.url.queryParameters.isEmpty) {
            return jsonResponse({
              'status': 'ok',
              'data': {'sid': 'sid1', 'nonce': '1a2b3c'},
            });
          }
          return jsonResponse({'status': 'ok'});
        }),
      );

      await client.actionNext();
      await client.actionNext();

      expect(calls.length, 4); // nonce, auth, two actions
      final auth = calls[1].queryParameters;
      expect(auth['rid'], '0');
      expect(
        auth['dtoken'],
        computeDtoken(nonce: '1a2b3c', rid: 0, token: 'abcdef', data: 'auth'),
      );
      expect(calls[2].queryParameters['rid'], '1');
      expect(calls[3].queryParameters['rid'], '2');
      expect(calls[3].queryParameters['sid'], 'sid1');
      expect(
        calls[3].queryParameters['dtoken'],
        computeDtoken(nonce: '1a2b3c', rid: 2, token: 'abcdef', data: '{}'),
      );
    });

    test('never puts the token in the URL', () async {
      final calls = <Uri>[];
      final client = HolyricsClient.local(
        host: 'h',
        port: 1,
        token: 'secret-token',
        httpClient: MockClient((request) async {
          calls.add(request.url);
          return jsonResponse({
            'status': 'ok',
            'data': {'sid': 's', 'nonce': 'n'},
          });
        }),
      );

      await client.actionNext();

      expect(calls.any((u) => u.toString().contains('secret-token')), isFalse);
    });
  });
}
