// Google login (same Firebase user as on the website) + reply notifications.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'core/fb_api.dart';
import 'core/fb_models.dart';
import 'google_login.dart';
import 'http_send.dart';

final FbApi fbApi = FbApi(apiKey: kFirebaseApiKey, projectId: kFirebaseProject, send: httpSend, referer: kSiteBase);

class AuthState extends ChangeNotifier {
  AuthSession? session;
  bool busy = false;

  /// Why the last sign-in failed (shown to the user); null when it did not fail.
  String? error;
  List<Notif> notifs = <Notif>[];

  bool get signedIn => session != null;
  int get unread => notifs.where((n) => !n.read).length;

  SharedPreferences? _prefs;

  /// Restores the saved login (no network needed; a fresh token is fetched when first required).
  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      _prefs = p;
      final uid = p.getString('fb_uid');
      final rt = p.getString('fb_rt');
      if (uid != null && uid.isNotEmpty && rt != null && rt.isNotEmpty) {
        session = AuthSession(
          uid: uid,
          name: p.getString('fb_name') ?? 'Student',
          photo: p.getString('fb_photo') ?? '',
          idToken: '',
          refreshToken: rt,
          expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
        );
        notifyListeners();
        unawaited(refreshNotifs());
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final s = session;
    final p = _prefs;
    if (s == null || p == null) return;
    try {
      await p.setString('fb_uid', s.uid);
      await p.setString('fb_name', s.name);
      await p.setString('fb_photo', s.photo);
      await p.setString('fb_rt', s.refreshToken);
    } catch (_) {}
  }

  /// Returns true when the user is signed in afterwards. [error] explains a failure.
  Future<bool> signIn() async {
    if (busy) return signedIn;
    busy = true;
    error = null;
    notifyListeners();
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final t = await googleSignInTokens();
      if (t == null) return signedIn; // closed the account picker
      session = await fbApi.signInWithGoogle(idToken: t.idToken, accessToken: t.accessToken);
      await _save();
      unawaited(refreshNotifs());
      return true;
    } on FbError catch (e) {
      error = 'Login nahi ho paya: ${e.code.isEmpty ? e.message : e.code}';
      await googleSignOut();
    } catch (e) {
      if (!isGoogleCancel(e)) error = describeGoogleError(e);
    } finally {
      busy = false;
      notifyListeners();
    }
    return signedIn;
  }

  Future<void> signOut() async {
    session = null;
    notifs = <Notif>[];
    error = null;
    try {
      final p = _prefs ?? await SharedPreferences.getInstance();
      await p.remove('fb_uid');
      await p.remove('fb_name');
      await p.remove('fb_photo');
      await p.remove('fb_rt');
    } catch (_) {}
    await googleSignOut();
    notifyListeners();
  }

  /// A valid id token for the signed-in user (refreshed when needed), or null when signed out / offline.
  Future<String?> token() async {
    final s = session;
    if (s == null) return null;
    if (s.idToken.isNotEmpty && s.expiresAt.isAfter(DateTime.now().add(const Duration(minutes: 5)))) return s.idToken;
    try {
      final n = await fbApi.refreshSession(s);
      if (session?.uid == s.uid) {
        session = n;
        await _save();
      }
      return n.idToken;
    } on FbError catch (e) {
      if (e.sessionDead) await signOut();
      return null;
    } catch (_) {
      return null; // offline: keep the login, try again later
    }
  }

  Future<void> refreshNotifs() async {
    final s = session;
    if (s == null) return;
    final tok = await token();
    if (tok == null) return;
    try {
      final list = await fbApi.listNotifs(s.uid, tok);
      if (session?.uid == s.uid) {
        notifs = list;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final s = session;
    if (s == null) return;
    final tok = await token();
    if (tok == null) return;
    final todo = notifs.where((n) => !n.read).toList();
    if (todo.isEmpty) return;
    notifs = <Notif>[
      for (final n in notifs)
        n.read ? n : Notif(id: n.id, fromName: n.fromName, text: n.text, lectureId: n.lectureId, read: true, ts: n.ts),
    ];
    notifyListeners();
    for (final n in todo) {
      try {
        await fbApi.markNotifRead(s.uid, n.id, tok);
      } catch (_) {}
    }
  }
}

final AuthState authState = AuthState();
