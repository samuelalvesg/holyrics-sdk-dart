import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Computes `sha256(nonce:rid:token:data)` as documented by the API Server.
String computeDtoken({
  required String nonce,
  required int rid,
  required String token,
  required String data,
}) =>
    sha256.convert(utf8.encode('$nonce:$rid:$token:$data')).toString();
