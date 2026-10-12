import 'dart:convert';

import 'package:http/http.dart' as http;

import '../exceptions/holyrics_exception.dart';

/// Decodes a response body into a JSON object.
Map<String, Object?> decodeResponseObject(http.Response response) {
  final Object? decoded;
  try {
    decoded = jsonDecode(utf8.decode(response.bodyBytes));
  } on FormatException {
    throw HolyricsApiException(
      'Invalid JSON response (HTTP ${response.statusCode})',
    );
  }
  if (decoded is! Map<String, Object?>) {
    throw HolyricsApiException('Unexpected response shape');
  }
  return decoded;
}

/// Returns `data` of an `ok` response or throws [HolyricsApiException].
Object? unwrapResponse(Map<String, Object?> json) {
  if (json['status'] == 'ok') return json['data'];
  final error = json['error'];
  if (error is Map) {
    throw HolyricsApiException(
      '${error['message'] ?? error['key'] ?? 'unknown error'}',
      code: error['code'] as int?,
      key: error['key'] as String?,
    );
  }
  throw HolyricsApiException('${error ?? 'unknown error'}');
}
