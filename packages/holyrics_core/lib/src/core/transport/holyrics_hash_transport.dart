import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/dtoken.dart';
import '../exceptions/holyrics_exception.dart';
import 'holyrics_transport.dart';
import 'response_parser.dart';

/// Local network transport that never sends the token: each request carries
/// a hash derived from a server nonce (see the API Server docs).
///
/// Authenticates lazily on the first request and keeps the session (`sid`,
/// `nonce`) with an increasing request id (`rid`).
class HolyricsHashTransport implements HolyricsTransport {
  HolyricsHashTransport({
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

  String? _sid;
  String? _nonce;
  int _rid = 0;

  @override
  Future<Object?> send(String action, Map<String, Object?> body) async {
    if (_sid == null) await _authenticate();
    final payload = jsonEncode(body);
    _rid++;
    final dtoken = computeDtoken(
      nonce: _nonce!,
      rid: _rid,
      token: token,
      data: payload,
    );
    final response = await _post(
      action,
      {'sid': _sid!, 'rid': '$_rid', 'dtoken': dtoken},
      payload,
    );
    return unwrapResponse(decodeResponseObject(response));
  }

  Future<void> _authenticate() async {
    final nonceResponse = await _post('Auth', const {}, '{}');
    final data = unwrapResponse(decodeResponseObject(nonceResponse));
    if (data is! Map) throw HolyricsApiException('Auth returned no nonce');
    final sid = data['sid'] as String;
    final nonce = data['nonce'] as String;
    final dtoken = computeDtoken(
      nonce: nonce,
      rid: 0,
      token: token,
      data: 'auth',
    );
    final response = await _post(
      'Auth',
      {'sid': sid, 'rid': '0', 'dtoken': dtoken},
      '{}',
    );
    unwrapResponse(decodeResponseObject(response));
    _sid = sid;
    _nonce = nonce;
    _rid = 0;
  }

  Future<http.Response> _post(
    String action,
    Map<String, String> query,
    String body,
  ) =>
      _client.post(
        Uri(
          scheme: secure ? 'https' : 'http',
          host: host,
          port: port,
          path: '/api/$action',
          queryParameters: query.isEmpty ? null : query,
        ),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

  @override
  void close() {
    if (_ownsClient) _client.close();
  }
}
