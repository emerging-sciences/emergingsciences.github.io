import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'core/js_literal.dart';
import 'core/models.dart';
import 'core/sheet_merge.dart';

const List<String> kSheetTabs = ['topics', 'lectures', 'material', 'pyqs', 'syllabus'];

/// The raw text the website itself is built from.
class RawSources {
  final String dataJs;
  final String sheetsJs;
  final Map<String, String> csv;
  RawSources(this.dataJs, this.sheetsJs, this.csv);

  Map<String, dynamic> toJson() => {'dataJs': dataJs, 'sheetsJs': sheetsJs, 'csv': csv};

  static RawSources? fromJson(Object? j) {
    if (j is! Map) return null;
    final data = j['dataJs'];
    if (data is! String || data.isEmpty) return null;
    final csv = <String, String>{};
    final c = j['csv'];
    if (c is Map) {
      c.forEach((k, v) {
        if (v is String) csv[k.toString()] = v;
      });
    }
    final sheets = j['sheetsJs'];
    return RawSources(data, sheets is String ? sheets : '', csv);
  }

  bool sameAs(RawSources o) {
    if (dataJs != o.dataJs || sheetsJs != o.sheetsJs || csv.length != o.csv.length) return false;
    for (final k in csv.keys) {
      if (csv[k] != o.csv[k]) return false;
    }
    return true;
  }
}

class BuiltData {
  final EsData data;
  final List<String> warnings;
  BuiltData(this.data, this.warnings);
}

/// data.js (+ Google Sheet tabs) -> typed data. Throws if data.js cannot be read.
BuiltData buildFrom(RawSources raw) {
  final parsed = parseJsAssignment(raw.dataJs, 'ES_DATA');
  if (parsed is! Map<String, dynamic>) {
    throw JsLiteralError('ES_DATA is not an object');
  }
  final warns = <String>[];
  if (raw.csv.isNotEmpty) {
    applySheetCsv(parsed, raw.csv, (m) => warns.add(m));
  }
  return BuiltData(EsData.fromMap(parsed), warns);
}

class DataRepo {
  static const String _cacheKey = 'es_raw_cache_v1';

  Future<RawSources?> readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_cacheKey);
      if (s == null || s.isEmpty) return null;
      return RawSources.fromJson(jsonDecode(s));
    } catch (_) {
      return null;
    }
  }

  Future<void> writeCache(RawSources raw) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(raw.toJson()));
    } catch (_) {}
  }

  /// Copy of the site taken when the APK was built (works on the very first start, even offline).
  Future<RawSources?> readBundled() async {
    try {
      final s = await rootBundle.loadString('assets/snapshot.json');
      return RawSources.fromJson(jsonDecode(s));
    } catch (_) {
      return null;
    }
  }

  Future<String?> getText(String url, {int seconds = 12}) async {
    try {
      final res = await http
          .get(Uri.parse(url), headers: const {'Cache-Control': 'no-cache'})
          .timeout(Duration(seconds: seconds));
      if (res.statusCode != 200) return null;
      return utf8.decode(res.bodyBytes, allowMalformed: true);
    } catch (_) {
      return null;
    }
  }

  static bool _looksLikeHtml(String t) => RegExp(r'^\s*<(!doctype|html)', caseSensitive: false).hasMatch(t);

  /// Downloads the current website data. Returns null when the website cannot be reached.
  Future<RawSources?> fetchLive(RawSources? previous) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final dataJs = await getText('${kSiteBase}data.js?t=$ts');
    if (dataJs == null || dataJs.isEmpty) return null;
    final sheetsJs = await getText('${kSiteBase}sheet-config.js?t=$ts') ?? previous?.sheetsJs ?? '';

    var pub = '';
    final gids = <String, String>{};
    try {
      final cfg = parseJsAssignment(sheetsJs, 'ES_SHEETS');
      if (cfg is Map) {
        pub = (cfg['pub'] ?? '').toString();
        final g = cfg['gids'];
        if (g is Map) {
          g.forEach((k, v) => gids[k.toString()] = (v ?? '').toString());
        }
      }
    } catch (_) {}

    final csv = <String, String>{};
    if (pub.isNotEmpty && gids.isNotEmpty) {
      await Future.wait(kSheetTabs.map((tab) async {
        final gid = gids[tab] ?? '';
        if (gid.isEmpty) return;
        final url = 'https://docs.google.com/spreadsheets/d/e/${Uri.encodeComponent(pub)}'
            '/pub?gid=${Uri.encodeComponent(gid)}&single=true&output=csv';
        final t = await getText(url, seconds: 15);
        if (t != null && !_looksLikeHtml(t)) {
          csv[tab] = t;
        } else if (previous != null && previous.csv[tab] != null) {
          csv[tab] = previous.csv[tab]!;
        }
      }));
    }
    return RawSources(dataJs, sheetsJs, csv);
  }
}
