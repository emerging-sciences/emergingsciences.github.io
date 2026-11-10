// "Someone replied to your comment" list (the website's 🔔 bell).
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../auth_state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'comments.dart';
import 'lectures.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Set<String> _fresh = <String>{}; // unread when the page was opened (kept highlighted)
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    await authState.refreshNotifs();
    if (!mounted) return;
    setState(() {
      _fresh = <String>{for (final n in authState.notifs) if (!n.read) n.id};
      _loading = false;
    });
    await authState.markAllRead();
  }

  Future<void> _refresh() async {
    await authState.refreshNotifs();
    if (!mounted) return;
    setState(() {
      _fresh = <String>{..._fresh, for (final n in authState.notifs) if (!n.read) n.id};
    });
    await authState.markAllRead();
  }

  @override
  Widget build(BuildContext context) {
    return EsPage(
      title: 'Notifications',
      body: ListenableBuilder(
        listenable: authState,
        builder: (context, _) {
          if (!authState.signedIn) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Reply notifications dekhne ke liye Google se sign in karo.', textAlign: TextAlign.center, style: kBody),
                    const SizedBox(height: 14),
                    Pill(
                      label: authState.busy ? 'Signing in…' : 'Sign in with Google',
                      icon: Icons.login,
                      filled: true,
                      onTap: authState.busy ? null : authState.signIn,
                    ),
                  ],
                ),
              ),
            );
          }
          if (_loading && authState.notifs.isEmpty) {
            return Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(C.blue)));
          }
          final items = authState.notifs;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('Abhi koi notification nahi.', textAlign: TextAlign.center, style: kBody),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final n = items[i];
                      final lec = appState.data?.lecture(n.lectureId);
                      final fresh = _fresh.contains(n.id);
                      return EsCard(
                        onTap: lec == null ? null : () => openLecture(context, lec, null),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5, right: 10),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: fresh ? C.blue : Colors.transparent, shape: BoxShape.circle),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${n.fromName} ne aapke comment par reply kiya', style: kTitle),
                                  if (n.text.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('“${n.text}”', maxLines: 3, overflow: TextOverflow.ellipsis, style: kBody),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    lec == null ? fmtWhen(n.ts) : '${lec.n} ${lec.t} · ${fmtWhen(n.ts)}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: kSmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
