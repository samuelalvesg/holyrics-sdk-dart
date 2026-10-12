import 'dart:convert';

import 'package:holyrics_core/holyrics_core.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

HolyricsClient _client(MockClientHandler handler) => HolyricsClient.local(
      host: 'h',
      port: 1,
      token: 't',
      useHash: false,
      httpClient: MockClient(handler),
    );

void main() {
  group('HolyricsClient', () {
    test('catalog covers the documented actions without duplicates', () {
      expect(holyricsActionNames.length, greaterThan(200));
      expect(
        holyricsActionNames,
        containsAll(['GetCurrentPresentation', 'ActionNext', 'ShowVerse']),
      );
      expect(holyricsActionNames.toSet().length, holyricsActionNames.length);
    });

    test('required params reach the wire with API names', () async {
      late String path;
      late Map<String, Object?> body;
      final client = _client((http.Request request) async {
        path = request.url.path;
        body = jsonDecode(request.body) as Map<String, Object?>;
        return http.Response('{"status":"ok"}', 200);
      });

      await client.actionGoToIndex(index: 3);

      expect(path, '/api/ActionGoToIndex');
      expect(body, {'index': 3});
    });

    test('call() drops null params and supports unknown actions', () async {
      late Map<String, Object?> body;
      final client = _client((http.Request request) async {
        body = jsonDecode(request.body) as Map<String, Object?>;
        return http.Response('{"status":"ok"}', 200);
      });

      await client.call('SomethingNew', {'a': 1, 'b': null});

      expect(body, {'a': 1});
    });
  });
}
