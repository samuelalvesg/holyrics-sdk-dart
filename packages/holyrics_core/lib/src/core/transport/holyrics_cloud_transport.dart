import 'dart:convert';

import 'package:http/http.dart' as http;

import '../exceptions/holyrics_exception.dart';
import 'holyrics_transport.dart';
import 'response_parser.dart';

/// Internet transport through the Holyrics cloud relay
/// (`https://api.holyrics.com.br`). Needs the API key shown in the API
/// Server settings.
class HolyricsCloudTransport implements HolyricsTransport {
  HolyricsCloudTransport({
    required this.apiKey,
    required this.token,
    this.waitForResponse = true,
    Uri? baseUri,
    http.Client? client,
  })  : baseUri = baseUri ?? Uri.parse('https://api.holyrics.com.br'),
        _client = client ?? http.Client(),
        _ownsClient = client == null;

  final String apiKey;
  final String token;

  /// True uses `/request/{action}` and waits for the response; false uses
  /// `/send/{action}` (fire and forget, returns null).
  final bool waitForResponse;
  final Uri baseUri;
  final http.Client _client;
  final bool _ownsClient;

  @override
  Future<Object?> send(String action, Map<String, Object?> body) async {
    final mode = waitForResponse ? 'request' : 'send';
    final response = await _client.post(
      baseUri.replace(path: '/$mode/$action'),
      headers: {
        'Content-Type': 'application/json',
        'api_key': apiKey,
        'token': token,
      },
      body: jsonEncode(body),
    );
    final json = decodeResponseObject(response);
    _throwOnRelayError(json);
    if (!waitForResponse) return null;
    if (json['response_status'] == 'timeout') {
      throw HolyricsCloudException(
        'Timed out waiting for Holyrics',
        key: 'timeout',
      );
    }
    final inner = json['response'];
    if (inner is! Map<String, Object?>) {
      throw HolyricsCloudException('Relay returned no response');
    }
    return unwrapResponse(inner);
  }

  void _throwOnRelayError(Map<String, Object?> json) {
    if (json['status'] == 'ok') return;
    final error = json['error'];
    if (error is Map) {
      throw HolyricsCloudException(
        '${error['message'] ?? error['key'] ?? 'relay error'}',
        code: error['code'] as int?,
        key: error['key'] as String?,
      );
    }
    throw HolyricsCloudException('${error ?? 'relay error'}');
  }

  @override
  void close() {
    if (_ownsClient) _client.close();
  }
}
