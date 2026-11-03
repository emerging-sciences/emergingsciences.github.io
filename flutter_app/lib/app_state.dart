import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'core/models.dart';
import 'core/progress_logic.dart';
import 'data_repo.dart';

class UpdateInfo {
  final int code;
  final String name, apk, notes;
  UpdateInfo(this.code, this.name, this.apk, this.notes);
}

/// One global state object: website data + the student's own progress (saved on this phone only).
class AppState extends ChangeNotifier {
  final DataRepo _repo = DataRepo();
  SharedPreferences? _prefs;
  RawSources? _raw;
  Timer? _timer;
  Timer? _flush;

  EsData? data;
  List<String> warnings = <String>[];
  bool ready = false;
  bool refreshing = false;
  bool offline = false;
  DateTime? lastRefresh;
  UpdateInfo? update;

  Set<String> done = <String>{};
  Set<String> saved = <String>{};
  Map<String, int> study = <String, int>{};
  int goalMin = 30;
  int _sinceNotify = 0;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadProgress();
    } catch (_) {}
    var ok = false;
    final cached = await _repo.readCache();
    if (cached != null) ok = _apply(cached);
    if (!ok) {
      final bundled = await _repo.readBundled();
      if (bundled != null) ok = _apply(bundled);
    }
    ready = true;
    notifyListeners();
    unawaited(refresh());
    unawaited(checkUpdate());
    _timer = Timer.periodic(kRefreshEvery, (_) => refresh());
  }

  bool _apply(RawSources raw) {
    try {
      final built = buildFrom(raw);
      data = built.data;
      warnings = built.warnings;
      _raw = raw;
      if (_prefs?.getInt('es_goal') == null) {
        goalMin = built.data.goalMin;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fetches the newest website content. Safe to call often.
  Future<void> refresh() async {
    if (refreshing) return;
    refreshing = true;
    notifyListeners();
    try {
      final live = await _repo.fetchLive(_raw);
      if (live == null) {
        offline = true;
      } else {
        offline = false;
        lastRefresh = DateTime.now();
        final r = _raw;
        if (r == null || !r.sameAs(live)) {
          if (_apply(live)) {
            await _repo.writeCache(live);
          }
        }
      }
    } catch (_) {
      offline = true;
    } finally {
      refreshing = false;
      notifyListeners();
    }
  }

  /// Called when the app comes back to the foreground.
  void refreshIfStale() {
    final t = lastRefresh;
    if (t == null || DateTime.now().difference(t).inSeconds > 60) {
      unawaited(refresh());
    }
  }

  Future<void> checkUpdate() async {
    try {
      final txt = await _repo.getText(kVersionUrl, seconds: 10);
      if (txt == null) return;
      final j = jsonDecode(txt);
      if (j is! Map) return;
      final code = j['versionCode'];
      final c = code is num ? code.toInt() : int.tryParse((code ?? '').toString()) ?? 0;
      if (c > kBuildNumber) {
        update = UpdateInfo(
          c,
          (j['versionName'] ?? '').toString(),
          (j['apk'] ?? kApkUrl).toString(),
          (j['notes'] ?? '').toString(),
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  // ------------------------------------------------------------------ progress (this phone only)

  void _loadProgress() {
    final p = _prefs;
    if (p == null) return;
    done = (p.getStringList('es_done') ?? <String>[]).toSet();
    saved = (p.getStringList('es_saved') ?? <String>[]).toSet();
    final g = p.getInt('es_goal');
    if (g != null && g >= 5) goalMin = g;
    try {
      final s = p.getString('es_study');
      if (s != null && s.isNotEmpty) {
        final j = jsonDecode(s);
        if (j is Map) {
          final m = <String, int>{};
          j.forEach((k, v) {
            if (v is num) m[k.toString()] = v.toInt();
          });
          study = m;
        }
      }
    } catch (_) {}
  }

  void _saveSets() {
    _prefs?.setStringList('es_done', done.toList());
    _prefs?.setStringList('es_saved', saved.toList());
  }

  bool isDone(String id) => done.contains(id);
  bool isSaved(String id) => saved.contains(id);

  void setDone(String id, bool v) {
    if (v) {
      done.add(id);
    } else {
      done.remove(id);
    }
    _saveSets();
    notifyListeners();
  }

  void toggleDone(String id) => setDone(id, !done.contains(id));

  void toggleSaved(String id) {
    if (!saved.remove(id)) saved.add(id);
    _saveSets();
    notifyListeners();
  }

  int get goalSeconds => goalMin * 60;
  int get todaySeconds => study[dayKey(DateTime.now())] ?? 0;
  int get streak => studyStreak(study, goalSeconds, DateTime.now());

  /// Called once per second while a lecture is playing.
  void addStudySecond() {
    final k = dayKey(DateTime.now());
    study[k] = (study[k] ?? 0) + 1;
    _sinceNotify++;
    if (_sinceNotify >= 15) {
      _sinceNotify = 0;
      notifyListeners();
    }
    _flush ??= Timer(const Duration(seconds: 10), () {
      _flush = null;
      _prefs?.setString('es_study', jsonEncode(study));
    });
  }

  void flushStudy({bool notify = true}) {
    _flush?.cancel();
    _flush = null;
    _prefs?.setString('es_study', jsonEncode(study));
    if (notify) notifyListeners();
  }

  /// Lets screens ask listeners to refresh (e.g. after leaving the player).
  void touch() => notifyListeners();

  void setGoal(int minutes) {
    goalMin = minutes < 5 ? 5 : (minutes > 600 ? 600 : minutes);
    _prefs?.setInt('es_goal', goalMin);
    notifyListeners();
  }

  void resetProgress() {
    done = <String>{};
    saved = <String>{};
    study = <String, int>{};
    _prefs?.remove('es_done');
    _prefs?.remove('es_saved');
    _prefs?.remove('es_study');
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flush?.cancel();
    super.dispose();
  }
}

final AppState appState = AppState();
