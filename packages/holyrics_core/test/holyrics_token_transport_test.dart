import 'dart:convert';

import 'package:holyrics_core/holyrics_core.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'helpers.dart';

HolyricsClient _client(MockClientHandler handler) => HolyricsClient.local(
      host: '10.0.0.5',
      port: 1234,
      token: 'abc',
      useHash: false,
      httpClient: MockClient(handler),
    );

void main() {
  group('HolyricsTokenTransport', () {
    test('posts to /api/{action} with the token in the query', () async {
      late http.Request seen;
      final client = _client((request) async {
        seen = request;
        return jsonResponse({
          'status': 'ok',
          'data': {'text': 'hi'},
        });
      });

      expect(await client.getCPInfo(), {'text': 'hi'});
      expect(seen.method, 'POST');
      expect(
        seen.url.toString(),
        'http://10.0.0.5:1234/api/GetCPInfo?token=abc',
      );
      expect(jsonDecode(seen.body), isEmpty);
    });

    test('omits null params and sends wire names', () async {
      late http.Request seen;
      final client = _client((request) async {
        seen = request;
        return jsonResponse({'status': 'ok'});
      });

      await client.getCurrentPresentation(includeSlides: true);

      expect(jsonDecode(seen.body), {'include_slides': true});
    });

    test('throws HolyricsApiException on status error', () async {
      final client = _client(
        (_) async => jsonResponse({
          'status': 'error',
          'error': 'invalid token',
        }),
      );

      expect(
        client.actionNext(),
        throwsA(
          isA<HolyricsApiException>()
              .having((e) => e.message, 'message', 'invalid token'),
        ),
      );
    });

    test('throws HolyricsApiException on a non-JSON body', () async {
      final client = _client((_) async => http.Response('oops', 200));

      expect(client.actionNext(), throwsA(isA<HolyricsApiException>()));
    });
  });
}
