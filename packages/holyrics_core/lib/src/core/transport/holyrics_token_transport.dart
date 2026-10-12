import 'dart:convert';

import 'package:http/http.dart' as http;

import 'holyrics_transport.dart';
import 'response_parser.dart';

/// Local network transport that sends the access token in the URL.
///
/// The token travels in clear text; prefer `HolyricsHashTransport` on
/// networks you do not trust.
class HolyricsTokenTransport implements HolyricsTransport {
  HolyricsTokenTransport({
    required this.host,
    required this.port,
    required this.token,
    this.secure = false,
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final String host;
  final int port;
  final String token;
  final bool secure;
  final http.Client _client;
  final bool _ownsClient;

  @override
  Future<Object?> send(String action, Map<String, Object?> body) async {
    final uri = Uri(
      scheme: secure ? 'https' : 'http',
      host: host,
      port: port,
      path: '/api/$action',
      queryParameters: {'token': token},
    );
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return unwrapResponse(decodeResponseObject(response));
  }

  @override
  void close() {
    if (_ownsClient) _client.close();
  }
}
