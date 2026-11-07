// Talks to the SAME Firebase project as the website (Auth + Firestore) over plain HTTPS/REST, so no Firebase
// plugin is needed. Pure Dart: the HTTP call itself is passed in as [HttpSend] (easy to test).
import 'dart:convert';

import 'fb_models.dart';
import 'fs_codec.dart';

class HttpReply {
  final int status;
  final String body;
  const HttpReply(this.status, this.body);
}

typedef HttpSend = Future<HttpReply> Function(String method, Uri url, Map<String, String> headers, String? body);

class FbError implements Exception {
  final int status;
  final String code;
  final String message;
  const FbError(this.status, this.code, this.message);

  /// The saved login can no longer be used (password/account changed, user removed ...): sign in again.
  bool get sessionDead =>
      code.contains('TOKEN_EXPIRED') ||
      code.contains('USER_DISABLED') ||
      code.contains('USER_NOT_FOUND') ||
      code.contains('INVALID_REFRESH_TOKEN') ||
      code.contains('INVALID_GRANT');
  bool get permission => status == 403 || code == 'PERMISSION_DENIED';
  bool get unauthenticated => status == 401 || code == 'UNAUTHENTICATED';

  @override
  String toString() => 'FbError($status, $code, $message)';
}

class FbApi {
  final String apiKey;
  final String projectId;
  final HttpSend send;
  final String? referer;
  FbApi({required this.apiKey, required this.projectId, required this.send, this.referer});

  String get _docs => 'projects/$projectId/databases/(default)/documents';

  // ---------------------------------------------------------------- plumbing

  Uri _fs(String path, {Map<String, String>? query}) =>
      Uri.https('firestore.googleapis.com', '/v1/$_docs/$path', <String, String>{'key': apiKey, ...?query});

  Map<String, String> _headers({String? token, String contentType = 'application/json; charset=utf-8'}) => <String, String>{
        'Content-Type': contentType,
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        if (referer != null) 'Referer': referer!,
      };

  FbError _error(HttpReply r) {
    var code = '';
    var msg = '';
    try {
      Object? j = jsonDecode(r.body);
      if (j is List && j.isNotEmpty) j = j.first;
      final e = j is Map ? j['error'] : null;
      if (e is Map) {
        code = '${e['status'] ?? ''}';
        msg = '${e['message'] ?? ''}';
        if (code.isEmpty && msg.isNotEmpty) code = msg.split(RegExp(r'[\s:]')).first;
      } else if (e is String) {
        code = e;
        msg = e;
      }
    } catch (_) {}
    if (msg.isEmpty) msg = r.body.length > 160 ? r.body.substring(0, 160) : r.body;
    return FbError(r.status, code, msg);
  }

  Future<Object?> _json(String method, Uri url, {Object? body, String? token}) async {
    final r = await send(method, url, _headers(token: token), body == null ? null : jsonEncode(body));
    if (r.status < 200 || r.status >= 300) throw _error(r);
    if (r.body.trim().isEmpty) return null;
    try {
      return jsonDecode(r.body);
    } catch (_) {
      throw FbError(r.status, 'BAD_JSON', 'Unexpected reply from server');
    }
  }

  void _checkId(String id) {
    if (id.isEmpty || id.contains('/')) throw const FbError(0, 'BAD_ID', 'Invalid id');
  }

  // ---------------------------------------------------------------- sign in (Firebase Auth REST)

  /// Exchanges a Google sign-in (id token and/or access token) for a Firebase login. Same user as on the website.
  Future<AuthSession> signInWithGoogle({String? idToken, String? accessToken}) async {
    final parts = <String>[];
    if (idToken != null && idToken.isNotEmpty) parts.add('id_token=${Uri.encodeQueryComponent(idToken)}');
    if (accessToken != null && accessToken.isNotEmpty) parts.add('access_token=${Uri.encodeQueryComponent(accessToken)}');
    if (parts.isEmpty) throw const FbError(0, 'NO_TOKEN', 'Google ne token nahi diya');
    parts.add('providerId=google.com');
    final url = Uri.https('identitytoolkit.googleapis.com', '/v1/accounts:signInWithIdp', <String, String>{'key': apiKey});
    final j = await _json('POST', url, body: <String, Object?>{
      'postBody': parts.join('&'),
      'requestUri': 'http://localhost',
      'returnSecureToken': true,
      'returnIdpCredential': true,
    });
    if (j is! Map) throw const FbError(0, 'BAD_JSON', 'Unexpected reply from server');
    final uid = '${j['localId'] ?? ''}';
    final token = '${j['idToken'] ?? ''}';
    final refresh = '${j['refreshToken'] ?? ''}';
    if (uid.isEmpty || token.isEmpty || refresh.isEmpty) throw const FbError(0, 'BAD_LOGIN', 'Login incomplete');
    var name = '${j['displayName'] ?? ''}'.trim();
    if (name.isEmpty) name = '${j['fullName'] ?? ''}'.trim();
    if (name.isEmpty) name = 'Student';
    return AuthSession(
      uid: uid,
      name: clip(name, 60),
      photo: '${j['photoUrl'] ?? ''}',
      idToken: token,
      refreshToken: refresh,
      expiresAt: _expiry(j['expiresIn']),
    );
  }

  DateTime _expiry(Object? expiresIn) {
    final secs = int.tryParse('$expiresIn') ?? 3600;
    return DateTime.now().add(Duration(seconds: secs));
  }

  /// New id token from the saved refresh token.
  Future<AuthSession> refreshSession(AuthSession s) async {
    final url = Uri.https('securetoken.googleapis.com', '/v1/token', <String, String>{'key': apiKey});
    final r = await send(
      'POST',
      url,
      _headers(contentType: 'application/x-www-form-urlencoded'),
      'grant_type=refresh_token&refresh_token=${Uri.encodeQueryComponent(s.refreshToken)}',
    );
    if (r.status < 200 || r.status >= 300) throw _error(r);
    Object? j;
    try {
      j = jsonDecode(r.body);
    } catch (_) {
      throw const FbError(0, 'BAD_JSON', 'Unexpected reply from server');
    }
    if (j is! Map) throw const FbError(0, 'BAD_JSON', 'Unexpected reply from server');
    final token = '${j['id_token'] ?? j['access_token'] ?? ''}';
    if (token.isEmpty) throw const FbError(0, 'BAD_LOGIN', 'Login incomplete');
    final rt = '${j['refresh_token'] ?? ''}';
    return s.copyWith(
      idToken: token,
      refreshToken: rt.isEmpty ? s.refreshToken : rt,
      expiresAt: _expiry(j['expires_in']),
    );
  }

  // ---------------------------------------------------------------- comments

  /// Newest 200 comments + replies of a lecture (public read, token optional).
  Future<List<Comment>> listComments(String lectureId, {String? token}) async {
    _checkId(lectureId);
    final j = await _json('POST', _fs('lectures/$lectureId:runQuery'), token: token, body: <String, Object?>{
      'structuredQuery': <String, Object?>{
        'from': <Object?>[<String, Object?>{'collectionId': 'comments'}],
        'orderBy': <Object?>[
          <String, Object?>{
            'field': <String, Object?>{'fieldPath': 'ts'},
            'direction': 'DESCENDING',
          },
        ],
        'limit': 200,
      },
    });
    final out = <Comment>[];
    if (j is List) {
      for (final e in j) {
        if (e is Map) {
          final d = decodeFsDoc(e['document']);
          if (d != null) out.add(Comment.fromDoc(d));
        }
      }
    }
    return out;
  }

  Future<void> postComment({
    required String lectureId,
    required AuthSession user,
    required String token,
    required String text,
    String? parentId,
    String? replyToUid,
  }) async {
    _checkId(lectureId);
    final id = newDocId();
    await _commit(<Object?>[
      <String, Object?>{
        'update': <String, Object?>{
          'name': '$_docs/lectures/$lectureId/comments/$id',
          'fields': encodeFsFields(<String, Object?>{
            'uid': user.uid,
            'name': clip(user.name, 60),
            'photo': user.photo,
            'text': clip(text, 500),
            'likedBy': <Object?>[],
            if (parentId != null) 'parentId': parentId,
            if (replyToUid != null) 'replyToUid': replyToUid,
          }),
        },
        'updateTransforms': <Object?>[
          <String, Object?>{'fieldPath': 'ts', 'setToServerValue': 'REQUEST_TIME'},
        ],
        'currentDocument': <String, Object?>{'exists': false},
      },
    ], token);
  }

  /// Adds / removes the user's id in the comment's likedBy list (arrayUnion / arrayRemove on the website).
  Future<void> setCommentLike({
    required String lectureId,
    required String commentId,
    required String uid,
    required bool like,
    required String token,
  }) async {
    _checkId(lectureId);
    _checkId(commentId);
    final transformKind = like ? 'appendMissingElements' : 'removeAllFromArray';
    await _commit(<Object?>[
      <String, Object?>{
        'update': <String, Object?>{'name': '$_docs/lectures/$lectureId/comments/$commentId', 'fields': <String, Object?>{}},
        'updateMask': <String, Object?>{'fieldPaths': <Object?>[]},
        'updateTransforms': <Object?>[
          <String, Object?>{
            'fieldPath': 'likedBy',
            transformKind: <String, Object?>{
              'values': <Object?>[<String, Object?>{'stringValue': uid}],
            },
          },
        ],
        'currentDocument': <String, Object?>{'exists': true},
      },
    ], token);
  }

  Future<void> deleteComment(String lectureId, String commentId, String token) async {
    _checkId(lectureId);
    _checkId(commentId);
    await _json('DELETE', _fs('lectures/$lectureId/comments/$commentId'), token: token);
  }

  // ---------------------------------------------------------------- lecture like / dislike

  Future<int> _countVotes(String lectureId, int v, String? token) async {
    final j = await _json('POST', _fs('lectures/$lectureId:runAggregationQuery'), token: token, body: <String, Object?>{
      'structuredAggregationQuery': <String, Object?>{
        'aggregations': <Object?>[
          <String, Object?>{'alias': 'c', 'count': <String, Object?>{}},
        ],
        'structuredQuery': <String, Object?>{
          'from': <Object?>[<String, Object?>{'collectionId': 'votes'}],
          'where': <String, Object?>{
            'fieldFilter': <String, Object?>{
              'field': <String, Object?>{'fieldPath': 'v'},
              'op': 'EQUAL',
              'value': <String, Object?>{'integerValue': '$v'},
            },
          },
        },
      },
    });
    if (j is List) {
      for (final e in j) {
        if (e is Map) {
          final res = e['result'];
          final af = res is Map ? res['aggregateFields'] : null;
          final c = af is Map ? af['c'] : null;
          if (c is Map) {
            final x = decodeFsValue(Map<String, dynamic>.from(c));
            if (x is int) return x;
          }
        }
      }
    }
    return 0;
  }

  Future<int> _myVote(String lectureId, String uid, String token) async {
    try {
      final j = await _json('GET', _fs('lectures/$lectureId/votes/$uid'), token: token);
      final d = decodeFsDoc(j);
      final v = d?.fields['v'];
      return v is int ? v : 0;
    } on FbError catch (e) {
      if (e.status == 404) return 0;
      rethrow;
    }
  }

  /// 👍 / 👎 counts for a lecture and (when signed in) this user's own vote.
  Future<VoteCounts> getVotes(String lectureId, {String? uid, String? token}) async {
    _checkId(lectureId);
    final counts = await Future.wait<int>(<Future<int>>[
      _countVotes(lectureId, 1, token),
      _countVotes(lectureId, -1, token),
    ]);
    var mine = 0;
    if (uid != null && token != null) {
      try {
        mine = await _myVote(lectureId, uid, token);
      } catch (_) {}
    }
    return VoteCounts(counts[0], counts[1], mine);
  }

  /// [value] 1 = like, -1 = dislike, 0 = remove my vote.
  Future<void> setVote(String lectureId, String uid, int value, String token) async {
    _checkId(lectureId);
    _checkId(uid);
    final url = _fs('lectures/$lectureId/votes/$uid');
    if (value == 0) {
      await _json('DELETE', url, token: token);
    } else {
      await _json('PATCH', url, token: token, body: <String, Object?>{
        'fields': encodeFsFields(<String, Object?>{'v': value}),
      });
    }
  }

  // ---------------------------------------------------------------- reply notifications

  Future<void> createReplyNotif({
    required String toUid,
    required AuthSession from,
    required String text,
    required String lectureId,
    required String token,
  }) async {
    _checkId(toUid);
    final id = newDocId();
    await _commit(<Object?>[
      <String, Object?>{
        'update': <String, Object?>{
          'name': '$_docs/users/$toUid/notifs/$id',
          'fields': encodeFsFields(<String, Object?>{
            'fromUid': from.uid,
            'fromName': clip(from.name, 60),
            'text': clip(text, 120),
            'lectureId': lectureId,
            'read': false,
          }),
        },
        'updateTransforms': <Object?>[
          <String, Object?>{'fieldPath': 'ts', 'setToServerValue': 'REQUEST_TIME'},
        ],
        'currentDocument': <String, Object?>{'exists': false},
      },
    ], token);
  }

  Future<List<Notif>> listNotifs(String uid, String token) async {
    _checkId(uid);
    final j = await _json('POST', _fs('users/$uid:runQuery'), token: token, body: <String, Object?>{
      'structuredQuery': <String, Object?>{
        'from': <Object?>[<String, Object?>{'collectionId': 'notifs'}],
        'orderBy': <Object?>[
          <String, Object?>{
            'field': <String, Object?>{'fieldPath': 'ts'},
            'direction': 'DESCENDING',
          },
        ],
        'limit': 30,
      },
    });
    final out = <Notif>[];
    if (j is List) {
      for (final e in j) {
        if (e is Map) {
          final d = decodeFsDoc(e['document']);
          if (d != null) out.add(Notif.fromDoc(d));
        }
      }
    }
    return out;
  }

  Future<void> markNotifRead(String uid, String notifId, String token) async {
    _checkId(uid);
    _checkId(notifId);
    await _json(
      'PATCH',
      _fs('users/$uid/notifs/$notifId', query: <String, String>{'updateMask.fieldPaths': 'read', 'currentDocument.exists': 'true'}),
      token: token,
      body: <String, Object?>{
        'fields': encodeFsFields(<String, Object?>{'read': true}),
      },
    );
  }

  // ---------------------------------------------------------------- commit

  Future<void> _commit(List<Object?> writes, String token) async {
    final url = Uri.https('firestore.googleapis.com', '/v1/$_docs:commit', <String, String>{'key': apiKey});
    await _json('POST', url, token: token, body: <String, Object?>{'writes': writes});
  }
}
