// Port of the website's app.js sheet loader (CSV parsing + merge into ES_DATA).
// Same rules as the website, so the app shows exactly what the website shows.
// No Flutter imports on purpose.

String _norm(Object? s) =>
    (s == null ? '' : s.toString()).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

String _txt(Object? s) => (s == null ? '' : s.toString())
    .replaceAll(RegExp(r'[<>]'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String _cleanId(Object? s) => (s == null ? '' : s.toString())
    .trim()
    .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-')
    .replaceAll(RegExp(r'-+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

String _httpUrl(Object? s) {
  final t = (s == null ? '' : s.toString()).trim();
  return RegExp(r'^https?://', caseSensitive: false).hasMatch(t) ? t : '';
}

String _ytId(Object? s) {
  final t = (s == null ? '' : s.toString()).trim();
  if (t.isEmpty) return '';
  final m = RegExp(r'(?:v=|youtu\.be/|embed/|shorts/|live/)([A-Za-z0-9_-]{6,20})').firstMatch(t);
  if (m != null) return m.group(1)!;
  return RegExp(r'^[A-Za-z0-9_-]{6,20}$').hasMatch(t) ? t : '';
}

String _driveId(Object? s) {
  final t = (s == null ? '' : s.toString()).trim();
  if (t.isEmpty) return '';
  final m = RegExp(r'/d/([A-Za-z0-9_-]{10,})').firstMatch(t) ??
      RegExp(r'[?&]id=([A-Za-z0-9_-]{10,})').firstMatch(t);
  if (m != null) return m.group(1)!;
  return RegExp(r'^[A-Za-z0-9_-]{10,}$').hasMatch(t) ? t : '';
}

int _parseIntPrefix(String s) {
  final m = RegExp(r'^\s*([+-]?\d+)').firstMatch(s);
  if (m == null) return 0;
  return int.tryParse(m.group(1)!) ?? 0;
}

/// RFC-4180 style CSV reader (same behaviour as the website's parseCSV).
List<List<String>> parseCsv(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  var f = StringBuffer();
  var q = false;
  final t = text.startsWith('﻿') ? text.substring(1) : text;
  for (var i = 0; i < t.length; i++) {
    final c = t[i];
    if (q) {
      if (c == '"') {
        if (i + 1 < t.length && t[i + 1] == '"') {
          f.write('"');
          i++;
        } else {
          q = false;
        }
      } else {
        f.write(c);
      }
    } else if (c == '"') {
      q = true;
    } else if (c == ',') {
      row.add(f.toString());
      f = StringBuffer();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < t.length && t[i + 1] == '\n') i++;
      row.add(f.toString());
      rows.add(row);
      row = <String>[];
      f = StringBuffer();
    } else {
      f.write(c);
    }
  }
  if (f.length > 0 || row.isNotEmpty) {
    row.add(f.toString());
    rows.add(row);
  }
  return rows;
}

const Map<String, String> _alias = {
  'topic': 'topic', 'topicid': 'topic', 'exams': 'exams', 'exam': 'exams', 'no': 'no',
  'number': 'no', 'num': 'no', 'lecture': 'no', 'title': 'title', 'name': 'name',
  'type': 'type', 'kind': 'type', 'youtube': 'youtube', 'youtubeid': 'youtube', 'yt': 'youtube',
  'video': 'youtube', 'id': 'id', 'icon': 'icon', 'subject': 'subject', 'paper': 'subject',
  'live': 'live', 'description': 'desc', 'desc': 'desc', 'drive': 'drive', 'driveid': 'drive',
  'file': 'drive', 'pdf': 'drive', 'year': 'year', 'questionpaper': 'qp', 'qp': 'qp',
  'paper_qp': 'qp', 'answerkey': 'key', 'key': 'key', 'group': 'group', 'note': 'note',
  'notes': 'note', 'link': 'link', 'url': 'link', 'source': 'src', 'src': 'src',
};

List<Map<String, String>> sheetRowsToObjects(List<List<String>> rows) {
  if (rows.length < 2) return <Map<String, String>>[];
  final h = rows[0].map((x) {
    final n = _norm(x);
    return _alias[n] ?? n;
  }).toList();
  final out = <Map<String, String>>[];
  for (var i = 1; i < rows.length; i++) {
    final r = rows[i];
    final o = <String, String>{};
    var any = false;
    for (var j = 0; j < h.length; j++) {
      final v = j < r.length ? r[j].trim() : '';
      if (v.isNotEmpty) any = true;
      if (h[j].isNotEmpty && !o.containsKey(h[j])) o[h[j]] = v;
    }
    if (any) {
      o['_row'] = '${i + 1}';
      out.add(o);
    }
  }
  return out;
}

String _g(Map<String, String> r, String k) => r[k] ?? '';

class _Ctx {
  final Map<String, String> exAlias = {};
  final Map<String, String> papAlias = {};
  final List<Map<String, dynamic>> examList;
  final void Function(String) warn;

  _Ctx(Map<String, dynamic> d, this.examList, this.warn) {
    for (final e in examList) {
      for (final n in [e['id'], e['short'], e['name']]) {
        final s = n == null ? '' : n.toString();
        if (s.isNotEmpty) exAlias[_norm(s)] = e['id'].toString();
      }
    }
    void alias(String a, String b) {
      final v = exAlias[a] ?? exAlias[b];
      if (v != null) exAlias[a] = v;
    }

    alias('iitjam', 'jam');
    alias('cuet', 'cuetpg');
    alias('csirnet', 'csir');
    alias('tifrgs', 'tifr');
    final papers = d['papers'];
    if (papers is List) {
      for (final p in papers) {
        if (p is Map) {
          final id = p['id']?.toString() ?? '';
          final name = p['name']?.toString() ?? '';
          papAlias[_norm(id)] = id;
          papAlias[_norm(name)] = id;
        }
      }
    }
  }

  List<String> papersOf(Map<String, dynamic> e) {
    final p = e['papers'];
    if (p is List) return p.map((x) => x.toString()).toList();
    return <String>[];
  }

  bool eligible(Map<String, dynamic> e, String p) {
    final ps = papersOf(e);
    if (ps.isNotEmpty) return ps.contains(p.isEmpty ? 'ma' : p);
    return p.isEmpty || p == 'ma';
  }

  String paper(String v0, String where) {
    final v = v0.trim();
    if (v.isEmpty) return '';
    final id = papAlias[_norm(v)];
    if (id == null || id.isEmpty) {
      warn('$where: unknown subject "$v"');
      return '';
    }
    return id;
  }

  /// null means "all exams"; otherwise a list of exam ids (possibly empty = invalid).
  List<String>? exams(String v0, String where) {
    final v = v0.trim();
    if (v.isEmpty || _norm(v) == 'all' || _norm(v) == 'sab') return null;
    final out = <String>[];
    for (final item0 in v.split(RegExp(r'[,;|\n]+'))) {
      final item = item0.trim();
      if (item.isEmpty) continue;
      final id = exAlias[_norm(item)];
      if (id != null) {
        if (!out.contains(id)) out.add(id);
        continue;
      }
      final parts = item.split(RegExp(r'\s+'));
      final bad = <String>[];
      for (final w in parts) {
        final k = exAlias[_norm(w)];
        if (k != null) {
          if (!out.contains(k)) out.add(k);
        } else {
          bad.add(w);
        }
      }
      if (bad.isNotEmpty) warn('$where: unknown exam "${bad.join(' ')}"');
    }
    return out;
  }
}

/// Merges sheet tabs into [d] (the parsed ES_DATA map) in place.
/// [t] maps tab name -> rows. Returns the list of tabs that were used.
List<String> mergeSheetTabs(
    Map<String, dynamic> d, Map<String, List<Map<String, String>>> t, void Function(String) warn) {
  final used = <String>[];
  final examsRaw = d['exams'];
  final examList = <Map<String, dynamic>>[];
  if (examsRaw is List) {
    for (final e in examsRaw) {
      if (e is Map<String, dynamic>) examList.add(e);
    }
  }
  final c = _Ctx(d, examList, warn);
  final subjectIds = <String>{};

  // ---- Topics ----
  final topics = t['topics'];
  if (topics != null && topics.isNotEmpty) {
    final subs = <Map<String, dynamic>>[];
    final per = <List<String>?>[];
    final seen = <String>{};
    for (final r in topics) {
      final w = 'Topics row ${_g(r, '_row')}';
      final id = _cleanId(_g(r, 'id'));
      final name = _txt(_g(r, 'name').isNotEmpty ? _g(r, 'name') : _g(r, 'title'));
      if (id.isEmpty || name.isEmpty) {
        warn('$w: needs id and name — skipped');
        continue;
      }
      if (seen.contains(id)) {
        warn('$w: duplicate topic id "$id" — skipped');
        continue;
      }
      seen.add(id);
      final p = c.paper(_g(r, 'subject'), w);
      final icon = _txt(_g(r, 'icon'));
      final o = <String, dynamic>{'id': id, 'name': name, 'icon': icon.isEmpty ? '📘' : icon};
      if (p.isNotEmpty && p != 'ma') o['p'] = p;
      final lv = _g(r, 'live');
      o['live'] = lv.trim().isEmpty ||
          RegExp(r'^(y|yes|true|1|live)$', caseSensitive: false).hasMatch(lv);
      final ex = c.exams(_g(r, 'exams'), w);
      if (ex != null && ex.isEmpty) {
        warn('$w: no valid exam in "${_g(r, 'exams')}" — topic skipped');
        continue;
      }
      subs.add(o);
      per.add(ex);
    }
    final prev = <String, List<String>>{};
    for (final e in examList) {
      prev[e['id'].toString()] = _subjectIdsOf(e);
      e['subjects'] = <dynamic>[];
    }
    for (var i = 0; i < subs.length; i++) {
      final s = subs[i];
      final ex = per[i];
      final sp = (s['p'] ?? '').toString();
      for (final e in examList) {
        final list = e['subjects'] as List<dynamic>;
        if (ex == null) {
          if (c.eligible(e, sp)) list.add(s['id']);
        } else if (ex.contains(e['id'].toString())) {
          list.add(s['id']);
          if (!c.eligible(e, sp)) {
            warn('Topic "${s['id']}" is listed for ${e['id']} but that exam has no "${sp.isEmpty ? 'ma' : sp}" subject — it will stay hidden');
          }
        }
      }
    }
    for (final e in examList) {
      final list = (e['subjects'] as List<dynamic>).map((x) => x.toString()).toList();
      final prevList = prev[e['id'].toString()] ?? <String>[];
      final keyed = <MapEntry<String, int>>[];
      for (var n = 0; n < list.length; n++) {
        final k = prevList.indexOf(list[n]);
        keyed.add(MapEntry<String, int>(list[n], k < 0 ? 1000000 + n : k));
      }
      keyed.sort((a, b) => a.value.compareTo(b.value));
      e['subjects'] = keyed.map((x) => x.key).toList();
    }
    d['subjects'] = subs;
    used.add('topics');
  }
  final subjectsNow = d['subjects'];
  if (subjectsNow is List) {
    for (final s in subjectsNow) {
      if (s is Map) subjectIds.add(s['id'].toString());
    }
  }

  // ---- Lectures ----
  final lectures = t['lectures'];
  if (lectures != null && lectures.isNotEmpty) {
    final out = <Map<String, dynamic>>[];
    final ids = <String>{};
    final cnt = <String, int>{};
    for (final r in lectures) {
      final w = 'Lectures row ${_g(r, '_row')}';
      final s = _cleanId(_g(r, 'topic'));
      final yt = _ytId(_g(r, 'youtube'));
      final title = _txt(_g(r, 'title'));
      if (s.isEmpty || !subjectIds.contains(s)) {
        warn('$w: topic "${_g(r, 'topic')}" not found in Topics — skipped');
        continue;
      }
      if (title.isEmpty || yt.isEmpty) {
        warn('$w: needs a title and a valid YouTube link/id — skipped');
        continue;
      }
      final rid = _cleanId(_g(r, 'id'));
      final id = rid.isNotEmpty ? rid : '$s-$yt';
      if (ids.contains(id)) {
        warn('$w: duplicate id "$id" — skipped');
        continue;
      }
      ids.add(id);
      cnt[s] = (cnt[s] ?? 0) + 1;
      final no = _txt(_g(r, 'no'));
      final k = cnt[s]!;
      final o = <String, dynamic>{
        'id': id,
        's': s,
        'n': no.isNotEmpty ? no : 'L-${k < 10 ? '0' : ''}$k',
        't': title,
        'k': RegExp(r'^p', caseSensitive: false).hasMatch(_g(r, 'type')) ? 'P' : 'T',
        'yt': yt,
      };
      final ex = c.exams(_g(r, 'exams'), w);
      if (ex != null && ex.isEmpty) {
        warn('$w: no valid exam in "${_g(r, 'exams')}" — row hidden');
        continue;
      }
      if (ex != null) o['ex'] = ex;
      out.add(o);
    }
    d['lectures'] = out;
    used.add('lectures');
  }

  // ---- Material ----
  final material = t['material'];
  if (material != null && material.isNotEmpty) {
    final out = <Map<String, dynamic>>[];
    final ids = <String>{};
    for (final r in material) {
      final w = 'Material row ${_g(r, '_row')}';
      final s = _cleanId(_g(r, 'topic'));
      final dr = _driveId(_g(r, 'drive'));
      final title = _txt(_g(r, 'title'));
      if (s.isEmpty || !subjectIds.contains(s)) {
        warn('$w: topic "${_g(r, 'topic')}" not found in Topics — skipped');
        continue;
      }
      if (title.isEmpty || dr.isEmpty) {
        warn('$w: needs a title and a valid Google Drive link/id — skipped');
        continue;
      }
      final rid = _cleanId(_g(r, 'id'));
      final id = rid.isNotEmpty ? rid : 'm-${dr.substring(0, dr.length < 14 ? dr.length : 14)}';
      if (ids.contains(id)) {
        warn('$w: duplicate id "$id" — skipped');
        continue;
      }
      ids.add(id);
      final kind = _txt(_g(r, 'type'));
      final o = <String, dynamic>{
        'id': id,
        't': title,
        'd': _txt(_g(r, 'desc')),
        'k': kind.isNotEmpty ? kind : 'Notes',
        's': s,
        'drive': dr,
      };
      final ex = c.exams(_g(r, 'exams'), w);
      if (ex != null && ex.isEmpty) {
        warn('$w: no valid exam in "${_g(r, 'exams')}" — row hidden');
        continue;
      }
      if (ex != null) o['ex'] = ex;
      out.add(o);
    }
    d['material'] = out;
    used.add('material');
  }

  // ---- PYQs ----
  final pyqs = t['pyqs'];
  if (pyqs != null && pyqs.isNotEmpty) {
    final out = <Map<String, dynamic>>[];
    for (final r in pyqs) {
      final w = 'PYQs row ${_g(r, '_row')}';
      final y = _parseIntPrefix(_g(r, 'year'));
      final qp = _httpUrl(_g(r, 'qp'));
      final key = _httpUrl(_g(r, 'key'));
      final title = _txt(_g(r, 'title'));
      final p = c.paper(_g(r, 'subject'), w);
      if (y == 0 || title.isEmpty || (qp.isEmpty && key.isEmpty)) {
        warn('$w: needs year, title and a link — skipped');
        continue;
      }
      final ex = c.exams(_g(r, 'exams'), w);
      if (ex != null && ex.isEmpty) {
        warn('$w: no valid exam in "${_g(r, 'exams')}" — row skipped');
        continue;
      }
      for (final e in examList) {
        final hit = ex == null ? c.eligible(e, p) : ex.contains(e['id'].toString());
        if (!hit) continue;
        final o = <String, dynamic>{'e': e['id']};
        if (p.isNotEmpty && p != 'ma') o['p'] = p;
        o['y'] = y;
        o['t'] = title;
        if (qp.isNotEmpty) o['qp'] = qp;
        if (_txt(_g(r, 'note')).isNotEmpty) o['n'] = _txt(_g(r, 'note'));
        if (key.isNotEmpty) o['key'] = key;
        if (_txt(_g(r, 'group')).isNotEmpty) o['g'] = _txt(_g(r, 'group'));
        out.add(o);
      }
    }
    d['pyqs'] = out;
    used.add('pyqs');
  }

  // ---- Syllabus ----
  final syllabus = t['syllabus'];
  if (syllabus != null && syllabus.isNotEmpty) {
    final out = <Map<String, dynamic>>[];
    for (final r in syllabus) {
      final w = 'Syllabus row ${_g(r, '_row')}';
      final u = _httpUrl(_g(r, 'link'));
      final title = _txt(_g(r, 'title'));
      final p = c.paper(_g(r, 'subject'), w);
      if (title.isEmpty || u.isEmpty) {
        warn('$w: needs a title and a link — skipped');
        continue;
      }
      final ex = c.exams(_g(r, 'exams'), w);
      if (ex != null && ex.isEmpty) {
        warn('$w: no valid exam in "${_g(r, 'exams')}" — row skipped');
        continue;
      }
      for (final e in examList) {
        final hit = ex == null ? c.eligible(e, p) : ex.contains(e['id'].toString());
        if (!hit) continue;
        final o = <String, dynamic>{'e': e['id']};
        if (p.isNotEmpty && p != 'ma') o['p'] = p;
        o['t'] = title;
        o['url'] = u;
        if (_txt(_g(r, 'src')).isNotEmpty) o['src'] = _txt(_g(r, 'src'));
        if (_txt(_g(r, 'note')).isNotEmpty) o['n'] = _txt(_g(r, 'note'));
        out.add(o);
      }
    }
    d['syllabus'] = out;
    used.add('syllabus');
  }
  return used;
}

List<String> _subjectIdsOf(Map<String, dynamic> e) {
  final s = e['subjects'];
  if (s is List) return s.map((x) => x.toString()).toList();
  return <String>[];
}

/// Convenience: raw CSV text per tab -> merge. Unknown / empty tabs are ignored.
List<String> applySheetCsv(
    Map<String, dynamic> d, Map<String, String> csvByTab, void Function(String) warn) {
  final t = <String, List<Map<String, String>>>{};
  csvByTab.forEach((name, text) {
    t[name] = sheetRowsToObjects(parseCsv(text));
  });
  return mergeSheetTabs(d, t, warn);
}
