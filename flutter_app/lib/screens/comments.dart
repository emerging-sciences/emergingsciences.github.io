// Lecture comments: 👍/👎 for the lecture, comments, likes and replies. Same Firebase data as the website, so a
// comment written in the app shows on the website and the other way round.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../auth_state.dart';
import '../config.dart';
import '../core/fb_models.dart';
import '../theme.dart';
import '../widgets.dart';

String fmtWhen(DateTime? t) {
  if (t == null) return 'just now';
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  if (d.inDays < 7) return '${d.inDays} d ago';
  const months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final l = t.toLocal();
  return '${l.day} ${months[l.month - 1]} ${l.year}';
}

class CommentsSection extends StatefulWidget {
  final String lectureId;
  const CommentsSection({super.key, required this.lectureId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> with WidgetsBindingObserver {
  List<Thread>? _threads;
  bool _loadFailed = false;
  VoteCounts _votes = const VoteCounts(0, 0, 0);
  String? _votesUid; // whose "my vote" is in _votes
  int _shown = 20;
  bool _posting = false;
  bool _loading = false;
  String? _lastUid;
  Timer? _poll;
  final TextEditingController _ctl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    authState.addListener(_onAuth);
    _lastUid = authState.session?.uid;
    _load(force: true);
    _startPoll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    authState.removeListener(_onAuth);
    _poll?.cancel();
    _ctl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load(force: true);
      _startPoll();
    } else if (state == AppLifecycleState.paused) {
      _poll?.cancel();
      _poll = null;
    }
  }

  void _startPoll() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 25), (_) => _load());
  }

  void _onAuth() {
    if (!mounted) return;
    final uid = authState.session?.uid;
    if (uid != _lastUid) {
      _lastUid = uid;
      _votes = VoteCounts(_votes.up, _votes.down, 0);
      _votesUid = null;
      _loadVotes();
    }
    setState(() {});
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  // ------------------------------------------------------------ loading

  Future<void> _load({bool force = false}) async {
    if (_loading && !force) return;
    _loading = true;
    try {
      await Future.wait<void>(<Future<void>>[_loadComments(), _loadVotes()]);
    } finally {
      _loading = false;
    }
  }

  Future<void> _loadComments() async {
    try {
      final tok = await authState.token();
      final list = await fbApi.listComments(widget.lectureId, token: tok);
      if (!mounted) return;
      setState(() {
        _threads = buildThreads(list);
        _loadFailed = false;
      });
    } catch (_) {
      if (mounted && _threads == null) setState(() => _loadFailed = true);
    }
  }

  Future<void> _loadVotes() async {
    try {
      final tok = await authState.token();
      final uid = authState.session?.uid;
      final v = await fbApi.getVotes(widget.lectureId, uid: tok == null ? null : uid, token: tok);
      if (!mounted) return;
      setState(() {
        _votes = v;
        _votesUid = tok == null ? null : uid;
      });
    } catch (_) {}
  }

  // ------------------------------------------------------------ actions

  Future<bool> _ensureSignedIn() async {
    if (authState.signedIn) return true;
    final ok = await authState.signIn();
    if (!ok && authState.error != null) _snack(authState.error!);
    return ok;
  }

  Future<void> _castVote(int val) async {
    if (!await _ensureSignedIn()) return;
    final s = authState.session;
    final tok = await authState.token();
    if (s == null || tok == null) {
      _snack('Dobara sign-in karo.');
      return;
    }
    if (_votesUid != s.uid) await _loadVotes();
    final prev = _votes;
    final newMine = prev.mine == val ? 0 : val;
    var up = prev.up;
    var down = prev.down;
    if (prev.mine == 1) up--;
    if (prev.mine == -1) down--;
    if (newMine == 1) up++;
    if (newMine == -1) down++;
    if (!mounted) return;
    setState(() => _votes = VoteCounts(math.max(0, up), math.max(0, down), newMine));
    try {
      await fbApi.setVote(widget.lectureId, s.uid, newMine, tok);
    } catch (_) {
      if (mounted) setState(() => _votes = prev);
      _snack('Vote save nahi hua. Thodi der baad try karo.');
      return;
    }
    _loadVotes();
  }

  Future<void> _post() async {
    final text = _ctl.text.trim();
    if (text.isEmpty || _posting) return;
    final s = authState.session;
    final tok = await authState.token();
    if (s == null || tok == null) {
      _snack('Dobara sign-in karo.');
      return;
    }
    setState(() => _posting = true);
    try {
      await fbApi.postComment(lectureId: widget.lectureId, user: s, token: tok, text: text);
      _ctl.clear();
      await _load(force: true);
    } catch (_) {
      _snack('Comment post nahi hua. Thodi der baad try karo.');
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<bool> _postReply(Thread t, Comment target, String text) async {
    final s = authState.session;
    final tok = await authState.token();
    if (s == null || tok == null) {
      _snack('Dobara sign-in karo.');
      return false;
    }
    try {
      await fbApi.postComment(
        lectureId: widget.lectureId,
        user: s,
        token: tok,
        text: text,
        parentId: t.top.id,
        replyToUid: target.uid,
      );
      if (target.uid.isNotEmpty && target.uid != s.uid) {
        try {
          await fbApi.createReplyNotif(toUid: target.uid, from: s, text: text, lectureId: widget.lectureId, token: tok);
        } catch (_) {}
      }
      await _load(force: true);
      return true;
    } catch (_) {
      _snack('Reply post nahi hua. Thodi der baad try karo.');
      return false;
    }
  }

  Future<void> _toggleLike(Comment c) async {
    if (!await _ensureSignedIn()) return;
    final s = authState.session;
    final tok = await authState.token();
    if (s == null || tok == null) {
      _snack('Dobara sign-in karo.');
      return;
    }
    final liked = c.likedBy.contains(s.uid);
    final next = liked ? <String>[for (final u in c.likedBy) if (u != s.uid) u] : <String>[...c.likedBy, s.uid];
    Comment swap(Comment x) => x.id == c.id ? x.withLikedBy(next) : x;
    final cur = _threads;
    if (cur != null && mounted) {
      setState(() {
        _threads = <Thread>[for (final t in cur) Thread(swap(t.top), <Comment>[for (final r in t.replies) swap(r)])];
      });
    }
    try {
      await fbApi.setCommentLike(lectureId: widget.lectureId, commentId: c.id, uid: s.uid, like: !liked, token: tok);
    } catch (_) {
      _snack('Like save nahi hua. Thodi der baad try karo.');
      _load(force: true);
    }
  }

  Future<void> _delete(Comment c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface2,
        content: const Text('Ye comment delete karein?', style: TextStyle(color: C.text)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: C.red))),
        ],
      ),
    );
    if (ok != true) return;
    final tok = await authState.token();
    if (tok == null) {
      _snack('Dobara sign-in karo.');
      return;
    }
    try {
      await fbApi.deleteComment(widget.lectureId, c.id, tok);
      await _load(force: true);
    } catch (_) {
      _snack('Delete nahi hua. Thodi der baad try karo.');
    }
  }

  // ------------------------------------------------------------ UI

  Widget _voteBar() {
    return Row(
      children: [
        Pill(label: '👍 ${_votes.up}', filled: _votes.mine == 1, onTap: () => _castVote(1)),
        const SizedBox(width: 8),
        Pill(label: '👎 ${_votes.down}', filled: _votes.mine == -1, onTap: () => _castVote(-1)),
      ],
    );
  }

  Widget _accountBar() {
    final s = authState.session;
    if (s == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(
            label: authState.busy ? 'Signing in…' : 'Sign in with Google to comment',
            icon: Icons.login,
            filled: true,
            onTap: authState.busy ? null : _ensureSignedIn,
          ),
          if (authState.error != null) ...[
            const SizedBox(height: 8),
            Text(authState.error!, style: const TextStyle(color: C.red, fontSize: 12.5, height: 1.35)),
            const SizedBox(height: 8),
            Pill(
              label: 'Website par comment karo',
              icon: Icons.open_in_new,
              onTap: () => openExternal(context, '${kSiteBase}watch.html?id=${Uri.encodeComponent(widget.lectureId)}'),
            ),
          ],
        ],
      );
    }
    return Row(
      children: [
        _Avatar(photo: s.photo, name: s.name, size: 28),
        const SizedBox(width: 8),
        Expanded(child: Text('Signed in as ${s.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: kBody)),
        TextButton(onPressed: authState.signOut, child: const Text('Sign out')),
      ],
    );
  }

  Widget _composer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _ctl,
          maxLength: 500,
          minLines: 2,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(color: C.text, fontSize: 14),
          cursorColor: C.blue,
          decoration: _fieldDecoration('Apna doubt ya comment likho…'),
        ),
        Pill(label: _posting ? 'Posting…' : 'Post', icon: Icons.send, filled: true, onTap: _posting ? null : _post),
      ],
    );
  }

  Widget _list() {
    final threads = _threads;
    if (threads == null) {
      if (_loadFailed) {
        return Row(
          children: [
            const Expanded(child: Text('Comments abhi load nahi ho paye.', style: kBody)),
            Pill(label: 'Retry', icon: Icons.refresh, onTap: () {
              setState(() => _loadFailed = false);
              _load(force: true);
            }),
          ],
        );
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(C.blue)),
          ),
        ),
      );
    }
    if (threads.isEmpty) {
      return const Text('Abhi koi comment nahi. Pehla comment aap karo!', style: kBody);
    }
    final myUid = authState.session?.uid;
    final shown = threads.take(_shown).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final t in shown)
          _ThreadView(
            key: ValueKey<String>(t.top.id),
            thread: t,
            myUid: myUid,
            onLike: _toggleLike,
            onDelete: _delete,
            ensureSignedIn: _ensureSignedIn,
            onReply: (target, text) => _postReply(t, target, text),
          ),
        if (threads.length > _shown)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Pill(label: 'Show more comments', icon: Icons.expand_more, onTap: () => setState(() => _shown += 20)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = authState.signedIn;
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _voteBar(),
          const SizedBox(height: 16),
          const Text('💬 Comments', style: TextStyle(color: C.text, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _accountBar(),
          if (signedIn) ...[const SizedBox(height: 8), _composer()],
          const SizedBox(height: 14),
          _list(),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration(String hint) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: C.border),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: kSmall,
    counterStyle: kSmall,
    filled: true,
    fillColor: C.surface2,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: C.blue),
    ),
  );
}

class _Avatar extends StatelessWidget {
  final String photo;
  final String name;
  final double size;
  const _Avatar({required this.photo, required this.name, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final letter = name.isEmpty ? '?' : String.fromCharCode(name.runes.first).toUpperCase();
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: C.surface2, shape: BoxShape.circle),
      child: Text(letter, style: TextStyle(color: C.text2, fontSize: size * 0.45, fontWeight: FontWeight.w700)),
    );
    if (!photo.startsWith('https://')) return fallback;
    return ClipOval(
      child: Image.network(
        photo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 2).round(),
        errorBuilder: (context, error, stack) => fallback,
      ),
    );
  }
}

class _ThreadView extends StatelessWidget {
  final Thread thread;
  final String? myUid;
  final void Function(Comment) onLike;
  final void Function(Comment) onDelete;
  final Future<bool> Function() ensureSignedIn;
  final Future<bool> Function(Comment target, String text) onReply;
  const _ThreadView({
    super.key,
    required this.thread,
    required this.myUid,
    required this.onLike,
    required this.onDelete,
    required this.ensureSignedIn,
    required this.onReply,
  });

  Widget _tile(Comment c) => _CommentTile(
        key: ValueKey<String>('c_${c.id}'),
        c: c,
        myUid: myUid,
        onLike: () => onLike(c),
        onDelete: () => onDelete(c),
        ensureSignedIn: ensureSignedIn,
        onReply: (text) => onReply(c, text),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tile(thread.top),
          if (thread.replies.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 16, top: 10),
              padding: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(border: Border(left: BorderSide(color: C.border, width: 2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final r in thread.replies)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _tile(r),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatefulWidget {
  final Comment c;
  final String? myUid;
  final VoidCallback onLike;
  final VoidCallback onDelete;
  final Future<bool> Function() ensureSignedIn;
  final Future<bool> Function(String text) onReply;
  const _CommentTile({
    super.key,
    required this.c,
    required this.myUid,
    required this.onLike,
    required this.onDelete,
    required this.ensureSignedIn,
    required this.onReply,
  });

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _replying = false;
  bool _sending = false;
  final TextEditingController _rc = TextEditingController();

  @override
  void dispose() {
    _rc.dispose();
    super.dispose();
  }

  Future<void> _startReply() async {
    if (_replying) {
      setState(() => _replying = false);
      return;
    }
    if (!await widget.ensureSignedIn()) return;
    if (!mounted) return;
    final prefill = '@${widget.c.name} ';
    setState(() {
      _replying = true;
      _rc.text = prefill;
      _rc.selection = TextSelection.collapsed(offset: prefill.length);
    });
  }

  Future<void> _send() async {
    final text = _rc.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final ok = await widget.onReply(text);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (ok) {
        _replying = false;
        _rc.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final mine = widget.myUid != null && widget.myUid == c.uid;
    final liked = widget.myUid != null && c.likedBy.contains(widget.myUid);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(photo: c.photo, name: c.name),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('${c.name} · ${fmtWhen(c.ts)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: kSmall),
                  ),
                  if (mine)
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text('🗑 Delete', style: TextStyle(color: C.red, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(c.text, style: const TextStyle(color: C.text, fontSize: 14, height: 1.4)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Pill(label: '👍 ${c.likedBy.length}', filled: liked, onTap: widget.onLike),
                  Pill(label: 'Reply', icon: Icons.reply, onTap: _startReply),
                ],
              ),
              if (_replying) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _rc,
                  autofocus: true,
                  maxLength: 500,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: C.text, fontSize: 14),
                  cursorColor: C.blue,
                  decoration: _fieldDecoration('Reply likho…'),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Pill(label: _sending ? 'Posting…' : 'Post reply', filled: true, onTap: _sending ? null : _send),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
