// Typed view of the website's ES_DATA + the same lookup rules app-core.js uses.
// No Flutter imports on purpose (so it can be unit-tested with plain Dart).

String _s(Object? v) => v == null ? '' : v.toString();

List<String> _strList(Object? v) {
  if (v is List) return v.map((x) => x.toString()).toList();
  return <String>[];
}

/// null = visible in every exam; otherwise the exam ids it is meant for.
List<String>? _exList(Object? v) {
  if (v == null) return null;
  if (v is String) return v == 'all' || v.isEmpty ? null : <String>[v];
  if (v is List) return v.map((x) => x.toString()).toList();
  return null;
}

bool _inEx(List<String>? ex, String? examId) =>
    examId == null || ex == null || ex.contains(examId);

class Paper {
  final String id, name, icon;
  Paper(this.id, this.name, this.icon);
}

class Topic {
  final String id, name, icon;
  final String p; // paper id, 'ma' when not set
  final bool live;
  Topic(this.id, this.name, this.icon, this.p, this.live);
}

class Exam {
  final String id, short, tag, color, name, body, date, dateText, note, site, desc;
  final List<String> papers, subjects;
  Exam({
    required this.id,
    required this.short,
    required this.tag,
    required this.color,
    required this.name,
    required this.body,
    required this.date,
    required this.dateText,
    required this.note,
    required this.site,
    required this.desc,
    required this.papers,
    required this.subjects,
  });
}

class Lecture {
  final String id, s, n, t, k, yt;
  final List<String>? ex;
  Lecture(this.id, this.s, this.n, this.t, this.k, this.yt, this.ex);
  bool get isPractice => k == 'P';
}

class StudyMaterial {
  final String id, t, d, k, s, drive;
  final List<String>? ex;
  StudyMaterial(this.id, this.t, this.d, this.k, this.s, this.drive, this.ex);
}

class Mock {
  final String id, e, s, p, t;
  final int q, min;
  Mock(this.id, this.e, this.s, this.p, this.t, this.q, this.min);
}

class Syllabus {
  final String e, p, t, url, drive, src, n;
  Syllabus(this.e, this.p, this.t, this.url, this.drive, this.src, this.n);
}

class Pyq {
  final String e, p, t, qp, key, qpDrive, keyDrive, g, n;
  final int y;
  Pyq(this.e, this.p, this.y, this.t, this.qp, this.key, this.qpDrive, this.keyDrive, this.g, this.n);
}

class Portal {
  final String url, label, more, moreLabel;
  Portal(this.url, this.label, this.more, this.moreLabel);
}

class FaqItem {
  final String q, a;
  FaqItem(this.q, this.a);
}

class UpdateItem {
  final String date, text;
  UpdateItem(this.date, this.text);
}

class EsData {
  final int goalMin;
  final List<Paper> papers;
  final List<Topic> subjects;
  final List<Exam> exams;
  final List<Lecture> lectures;
  final List<StudyMaterial> material;
  final List<Mock> mocks;
  final List<Syllabus> syllabus;
  final List<Pyq> pyqs;
  final Map<String, Portal> portals;
  final List<FaqItem> faq;
  final List<UpdateItem> updates;
  final Map<String, String> links;

  EsData({
    required this.goalMin,
    required this.papers,
    required this.subjects,
    required this.exams,
    required this.lectures,
    required this.material,
    required this.mocks,
    required this.syllabus,
    required this.pyqs,
    required this.portals,
    required this.faq,
    required this.updates,
    required this.links,
  });

  static const String defaultPaper = 'ma';

  static List<Map<String, dynamic>> _maps(Object? v) {
    final out = <Map<String, dynamic>>[];
    if (v is List) {
      for (final x in v) {
        if (x is Map) {
          out.add(x.map((k, val) => MapEntry(k.toString(), val)));
        }
      }
    }
    return out;
  }

  factory EsData.fromMap(Map<String, dynamic> d) {
    final papers = _maps(d['papers'])
        .map((m) => Paper(_s(m['id']), _s(m['name']), _s(m['icon'])))
        .where((p) => p.id.isNotEmpty)
        .toList();
    final subjects = _maps(d['subjects'])
        .map((m) => Topic(_s(m['id']), _s(m['name']), _s(m['icon']),
            _s(m['p']).isEmpty ? defaultPaper : _s(m['p']), m['live'] == true))
        .where((t) => t.id.isNotEmpty)
        .toList();
    final exams = _maps(d['exams'])
        .map((m) => Exam(
              id: _s(m['id']),
              short: _s(m['short']),
              tag: _s(m['tag']).replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n'),
              color: _s(m['color']),
              name: _s(m['name']),
              body: _s(m['body']),
              date: _s(m['date']),
              dateText: _s(m['dateText']),
              note: _s(m['note']),
              site: _s(m['site']),
              desc: _s(m['desc']),
              papers: _strList(m['papers']),
              subjects: _strList(m['subjects']),
            ))
        .where((e) => e.id.isNotEmpty)
        .toList();
    final lectures = _maps(d['lectures'])
        .map((m) => Lecture(_s(m['id']), _s(m['s']), _s(m['n']), _s(m['t']), _s(m['k']),
            _s(m['yt']), _exList(m['ex'])))
        .where((l) => l.id.isNotEmpty && l.yt.isNotEmpty)
        .toList();
    final material = _maps(d['material'])
        .map((m) => StudyMaterial(_s(m['id']), _s(m['t']), _s(m['d']),
            _s(m['k']).isEmpty ? 'Notes' : _s(m['k']), _s(m['s']), _s(m['drive']), _exList(m['ex'])))
        .where((m) => m.id.isNotEmpty)
        .toList();
    final mocks = _maps(d['mocks'])
        .map((m) => Mock(
              _s(m['id']),
              _s(m['e']),
              _s(m['s']),
              _s(m['p']).isEmpty ? defaultPaper : _s(m['p']),
              _s(m['t']),
              m['q'] is num ? (m['q'] as num).toInt() : 0,
              m['min'] is num ? (m['min'] as num).toInt() : 0,
            ))
        .where((m) => m.id.isNotEmpty)
        .toList();
    final syllabus = _maps(d['syllabus'])
        .map((m) => Syllabus(_s(m['e']), _s(m['p']).isEmpty ? defaultPaper : _s(m['p']),
            _s(m['t']), _s(m['url']), _s(m['drive']), _s(m['src']), _s(m['n'])))
        .toList();
    final pyqs = _maps(d['pyqs'])
        .map((m) => Pyq(
              _s(m['e']),
              _s(m['p']).isEmpty ? defaultPaper : _s(m['p']),
              m['y'] is num ? (m['y'] as num).toInt() : (int.tryParse(_s(m['y'])) ?? 0),
              _s(m['t']),
              _s(m['qp']),
              _s(m['key']),
              _s(m['qpDrive']),
              _s(m['keyDrive']),
              _s(m['g']),
              _s(m['n']),
            ))
        .toList();
    final portals = <String, Portal>{};
    final pp = d['pyqPortals'];
    if (pp is Map) {
      pp.forEach((k, v) {
        if (v is Map) {
          portals[k.toString()] =
              Portal(_s(v['url']), _s(v['label']), _s(v['more']), _s(v['moreLabel']));
        }
      });
    }
    final faq = _maps(d['faq']).map((m) => FaqItem(_s(m['q']), _s(m['a']))).toList();
    final updates = _maps(d['updates']).map((m) => UpdateItem(_s(m['date']), _s(m['text']))).toList();
    final links = <String, String>{};
    final lk = d['links'];
    if (lk is Map) {
      lk.forEach((k, v) => links[k.toString()] = _s(v));
    }
    final goal = d['goalMin'];
    return EsData(
      goalMin: goal is num && goal > 0 ? goal.toInt() : 30,
      papers: papers,
      subjects: subjects,
      exams: exams,
      lectures: lectures,
      material: material,
      mocks: mocks,
      syllabus: syllabus,
      pyqs: pyqs,
      portals: portals,
      faq: faq,
      updates: updates,
      links: links,
    );
  }

  // ------------------------------------------------------------------ lookups

  Exam? exam(String? id) {
    if (id == null) return null;
    for (final e in exams) {
      if (e.id == id) return e;
    }
    return null;
  }

  Topic? topic(String? id) {
    if (id == null) return null;
    for (final t in subjects) {
      if (t.id == id) return t;
    }
    return null;
  }

  Paper? paper(String? id) {
    if (id == null) return null;
    for (final p in papers) {
      if (p.id == id) return p;
    }
    return null;
  }

  Lecture? lecture(String? id) {
    if (id == null) return null;
    for (final l in lectures) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// First exam that lists this topic (used when no exam is known).
  Exam? examOf(String topicId) {
    for (final e in exams) {
      if (e.subjects.contains(topicId)) return e;
    }
    return null;
  }

  List<Paper> papersOf(Exam e) {
    final out = <Paper>[];
    for (final id in e.papers) {
      final p = paper(id);
      if (p != null) out.add(p);
    }
    return out;
  }

  bool hasPapers(Exam e) => papersOf(e).isNotEmpty;

  /// Topics of an exam; when the exam has papers, only those of paper [p].
  List<Topic> topicsOf(Exam ex, String? p) {
    final out = <Topic>[];
    final hp = hasPapers(ex);
    for (final id in ex.subjects) {
      final t = topic(id);
      if (t == null) continue;
      if (!hp || t.p == p) out.add(t);
    }
    return out;
  }

  List<Lecture> lecturesOf(String topicId, {String? examId}) =>
      lectures.where((l) => l.s == topicId && _inEx(l.ex, examId)).toList();

  List<StudyMaterial> materialOf(String topicId, {String? examId}) =>
      material.where((m) => m.s == topicId && _inEx(m.ex, examId)).toList();

  List<Mock> mocksOf(Exam ex, String sid, String? p) => mocks
      .where((m) => m.e == ex.id && m.s == sid && (p == null || sid != 'full' || m.p == p))
      .toList();

  List<Syllabus> syllabusOf(String examId, String? p) =>
      syllabus.where((r) => r.e == examId && (p == null || r.p == p)).toList();

  List<Pyq> pyqsOf(String examId, String? p) {
    final rows = pyqs.where((r) => r.e == examId && (p == null || r.p == p)).toList();
    // Dart's sort is not stable; keep the sheet/data.js order for papers of the same year.
    final idx = <Pyq, int>{};
    for (var i = 0; i < rows.length; i++) {
      idx[rows[i]] = i;
    }
    rows.sort((a, b) {
      final c = b.y.compareTo(a.y);
      return c != 0 ? c : idx[a]!.compareTo(idx[b]!);
    });
    return rows;
  }

  Portal? portalOf(String examId, String? p) {
    if (p != null && portals.containsKey('$examId-$p')) return portals['$examId-$p'];
    return portals[examId];
  }

  // ------------------------------------------------------------------ dates

  static DateTime? _parseDate(String s) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
    if (m == null) return null;
    return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
  }

  /// Whole days from [now] (date part only) until the exam's first day. null when the date is unknown.
  int? daysLeft(Exam e, DateTime now) {
    final d = _parseDate(e.date);
    if (d == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    return (d.difference(today).inMinutes / 1440).round();
  }

  String countdownText(Exam e, DateTime now) {
    final d = daysLeft(e, now);
    if (d == null) return e.dateText;
    if (d > 0) return '$d day${d == 1 ? '' : 's'} left';
    if (d == 0) return 'Today';
    return 'Exam held · next date awaited';
  }

  /// Next upcoming exam (smallest non-negative days left).
  Exam? upcomingExam(DateTime now) {
    Exam? best;
    var bestDays = 1 << 30;
    for (final e in exams) {
      final d = daysLeft(e, now);
      if (d != null && d >= 0 && d < bestDays) {
        best = e;
        bestDays = d;
      }
    }
    return best;
  }

  // ------------------------------------------------------------------ labels (same wording as the website)

  String examPickLabel(String page, Exam e) {
    if (hasPapers(e) && page != 'mock') return '${papersOf(e).length} subjects';
    if (page == 'mock') {
      final n = mocks.where((m) => m.e == e.id).length;
      return '$n test${n == 1 ? '' : 's'}';
    }
    if (page == 'material') {
      final n = e.subjects.where((i) => material.any((m) => m.s == i && _inEx(m.ex, e.id))).length;
      return '$n of ${e.subjects.length} subjects with PDFs';
    }
    final n = e.subjects.where((i) {
      final t = topic(i);
      return t != null && t.live && lectures.any((l) => l.s == i && _inEx(l.ex, e.id));
    }).length;
    return '$n of ${e.subjects.length} subjects live';
  }

  String paperPickLabel(String page, Exam ex, Paper pp) {
    final topics = topicsOf(ex, pp.id);
    if (page == 'lectures') {
      var k = 0;
      for (final t in topics) {
        k += lecturesOf(t.id, examId: ex.id).length;
      }
      return k > 0 ? '$k lectures' : 'Syllabus & PYQs · lectures coming soon';
    }
    if (page == 'material') {
      var k = 0;
      for (final t in topics) {
        k += materialOf(t.id, examId: ex.id).length;
      }
      return k > 0 ? '$k PDFs · Syllabus · PYQs' : 'Syllabus & PYQs';
    }
    final k = mocks
        .where((m) => m.e == ex.id && (m.s == 'full' ? m.p == pp.id : topics.any((t) => t.id == m.s)))
        .length;
    return k > 0 ? '$k test${k == 1 ? '' : 's'}' : 'Syllabus & PYQs · tests coming soon';
  }

  /// Does a topic have content for this page? (used to grey out "coming soon" rows)
  String? topicBadge(String page, Exam ex, Topic t, String? p) {
    if (page == 'mock') {
      final n = mocksOf(ex, t.id, p).length;
      return n == 0 ? null : '$n test${n == 1 ? '' : 's'}';
    }
    if (page == 'material') {
      final n = materialOf(t.id, examId: ex.id).length;
      return n == 0 ? null : '$n PDF${n == 1 ? '' : 's'}';
    }
    if (!t.live) return null;
    final n = lecturesOf(t.id, examId: ex.id).length;
    return n == 0 ? null : '$n lectures';
  }
}
