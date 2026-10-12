import 'dart:convert';

import 'package:http/http.dart' as http;

http.Response jsonResponse(Object body) => http.Response(
      jsonEncode(body),
      200,
      headers: {'content-type': 'application/json'},
    );
