// Data shapes of the website's comments system (same Firestore documents as comments.js / notify.js).
import 'fs_codec.dart';

class AuthSession {
  final String uid;
  final String name;
  final String photo;
  final String idToken;
  final String refreshToken;
  final DateTime expiresAt;
  const AuthSession({
    required this.uid,
    required this.name,
    required this.photo,
    required this.idToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  AuthSession copyWith({String? idToken, String? refreshToken, DateTime? expiresAt}) => AuthSession(
        uid: uid,
        name: name,
        photo: photo,
        idToken: idToken ?? this.idToken,
        refreshToken: refreshToken ?? this.refreshToken,
        expiresAt: expiresAt ?? this.expiresAt,
      );
}

/// lectures/{lectureId}/comments/{id}  (a reply has parentId = id of the top-level comment)
class Comment {
  final String id;
  final String uid;
  final String name;
  final String photo;
  final String text;
  final List<String> likedBy;
  final String parentId;
  final String replyToUid;
  final DateTime? ts;
  const Comment({
    required this.id,
    required this.uid,
    required this.name,
    required this.photo,
    required this.text,
    required this.likedBy,
    required this.parentId,
    required this.replyToUid,
    required this.ts,
  });

  factory Comment.fromDoc(FsDoc d) {
    final f = d.fields;
    final liked = f['likedBy'];
    final name = f['name'];
    return Comment(
      id: d.id,
      uid: f['uid'] is String ? f['uid'] as String : '',
      name: name is String && name.isNotEmpty ? name : 'Student',
      photo: f['photo'] is String ? f['photo'] as String : '',
      text: f['text'] is String ? f['text'] as String : '',
      likedBy: liked is List ? <String>[for (final x in liked) if (x is String) x] : <String>[],
      parentId: f['parentId'] is String ? f['parentId'] as String : '',
      replyToUid: f['replyToUid'] is String ? f['replyToUid'] as String : '',
      ts: f['ts'] is DateTime ? f['ts'] as DateTime : null,
    );
  }

  Comment withLikedBy(List<String> l) => Comment(
        id: id,
        uid: uid,
        name: name,
        photo: photo,
        text: text,
        likedBy: l,
        parentId: parentId,
        replyToUid: replyToUid,
        ts: ts,
      );
}

class Thread {
  final Comment top;
  final List<Comment> replies; // oldest first
  const Thread(this.top, this.replies);
}

/// Same grouping as the website: [newestFirst] is the query result (newest first); top-level comments keep
/// that order, replies under each comment are shown oldest first. Replies whose parent is not in the list are dropped.
List<Thread> buildThreads(List<Comment> newestFirst) {
  final tops = <Comment>[];
  final kids = <String, List<Comment>>{};
  for (final c in newestFirst) {
    if (c.parentId.isNotEmpty) {
      (kids[c.parentId] ??= <Comment>[]).add(c);
    } else {
      tops.add(c);
    }
  }
  return <Thread>[for (final t in tops) Thread(t, (kids[t.id] ?? <Comment>[]).reversed.toList())];
}

/// users/{uid}/notifs/{id}: "someone replied to your comment"
class Notif {
  final String id;
  final String fromName;
  final String text;
  final String lectureId;
  final bool read;
  final DateTime? ts;
  const Notif({required this.id, required this.fromName, required this.text, required this.lectureId, required this.read, required this.ts});

  factory Notif.fromDoc(FsDoc d) {
    final f = d.fields;
    return Notif(
      id: d.id,
      fromName: f['fromName'] is String && (f['fromName'] as String).isNotEmpty ? f['fromName'] as String : 'Koi',
      text: f['text'] is String ? f['text'] as String : '',
      lectureId: f['lectureId'] is String ? f['lectureId'] as String : '',
      read: f['read'] == true,
      ts: f['ts'] is DateTime ? f['ts'] as DateTime : null,
    );
  }
}

class VoteCounts {
  final int up;
  final int down;
  final int mine; // 1, -1 or 0
  const VoteCounts(this.up, this.down, this.mine);
}
