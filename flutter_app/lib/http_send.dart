// The real network call behind core/fb_api.dart.
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'core/fb_api.dart';

final http.Client _client = http.Client();

Future<HttpReply> httpSend(String method, Uri url, Map<String, String> headers, String? body) async {
  final req = http.Request(method, url);
  req.headers.addAll(headers);
  if (body != null) req.body = body;
  final streamed = await _client.send(req).timeout(const Duration(seconds: 25));
  final res = await http.Response.fromStream(streamed);
  return HttpReply(res.statusCode, utf8.decode(res.bodyBytes, allowMalformed: true));
}
