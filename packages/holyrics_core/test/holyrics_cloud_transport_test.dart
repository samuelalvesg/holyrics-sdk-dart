import 'package:holyrics_core/holyrics_core.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'helpers.dart';

HolyricsClient _client(
  MockClientHandler handler, {
  bool waitForResponse = true,
}) =>
    HolyricsClient.cloud(
      apiKey: 'KEY',
      token: 'tok',
      waitForResponse: waitForResponse,
      httpClient: MockClient(handler),
    );

void main() {
  group('HolyricsCloudTransport', () {
    test('uses /request with api_key and token headers', () async {
      late http.Request seen;
      final client = _client((request) async {
        seen = request;
        return jsonResponse({
          'status': 'ok',
          'response_status': 'ok',
          'response': {
            'status': 'ok',
            'data': {'text': 'x'},
          },
        });
      });

      expect(await client.getCPInfo(), {'text': 'x'});
      expect(
        seen.url.toString(),
        'https://api.holyrics.com.br/request/GetCPInfo',
      );
      expect(seen.headers['api_key'], 'KEY');
      expect(seen.headers['token'], 'tok');
    });

    test('maps a relay error to HolyricsCloudException', () async {
      final client = _client(
        (_) async => jsonResponse({
          'status': 'error',
          'error': {
            'code': 9,
            'key': 'device_disconnected',
            'message': 'Device disconnected',
          },
        }),
      );

      expect(
        client.actionNext(),
        throwsA(
          isA<HolyricsCloudException>()
              .having((e) => e.key, 'key', 'device_disconnected')
              .having((e) => e.code, 'code', 9),
        ),
      );
    });

    test('throws on response timeout', () async {
      final client = _client(
        (_) async => jsonResponse({
          'status': 'ok',
          'response_status': 'timeout',
        }),
      );

      expect(client.actionNext(), throwsA(isA<HolyricsCloudException>()));
    });

    test('surfaces an error of the inner response as HolyricsApiException',
        () async {
      final client = _client(
        (_) async => jsonResponse({
          'status': 'ok',
          'response_status': 'ok',
          'response': {'status': 'error', 'error': 'invalid token'},
        }),
      );

      expect(client.actionNext(), throwsA(isA<HolyricsApiException>()));
    });

    test('send mode uses /send and returns null', () async {
      late http.Request seen;
      final client = _client(
        (request) async {
          seen = request;
          return jsonResponse({'status': 'ok'});
        },
        waitForResponse: false,
      );

      expect(await client.actionNext(), isNull);
      expect(seen.url.path, '/send/ActionNext');
    });
  });
}
