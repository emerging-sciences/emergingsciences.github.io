import 'package:flutter/material.dart';

import '../app_state.dart';
import '../auth_state.dart';
import '../config.dart';
import '../theme.dart';
import '../widgets.dart';
import 'lectures.dart';
import 'search.dart';
import 'study_material.dart';
import 'web_page.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        title: const Text('Reset my progress?', style: TextStyle(color: C.text)),
        content: const Text(
          'This deletes completed lectures, saved items and your study streak on this phone.',
          style: kBody,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) appState.resetProgress();
  }

  void _showNotes(BuildContext context) {
    final w = appState.warnings;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        title: const Text('Content check', style: TextStyle(color: C.text)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              w.isEmpty ? 'No problems found in the website data or the Google Sheet.' : w.join('\n\n'),
              style: kBody,
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EsPage(
      title: 'More',
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SearchScreen())),
        ),
      ],
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final data = appState.data;
          if (data == null) return const CenterMessage('Loading…');
          final savedLectures = data.lectures.where((l) => appState.isSaved(l.id)).toList();
          final savedMaterial = data.material.where((m) => appState.isSaved(m.id)).toList();
          final u = appState.update;
          return RefreshIndicator(
            onRefresh: appState.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                if (u != null)
                  EsCard(
                    onTap: () => openExternal(context, u.apk),
                    child: Row(
                      children: [
                        const Icon(Icons.system_update, color: C.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('New app version available${u.name.isEmpty ? '' : ' · v${u.name}'} — tap to download', style: kTitle),
                        ),
                      ],
                    ),
                  ),
                const SectionLabel('Account'),
                ListenableBuilder(
                  listenable: authState,
                  builder: (context, _) {
                    final s = authState.session;
                    if (s == null) {
                      return EsCard(
                        onTap: authState.busy ? null : authState.signIn,
                        child: Row(
                          children: [
                            const Icon(Icons.login, color: C.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(authState.busy ? 'Signing in…' : 'Sign in with Google', style: kTitle),
                                  const SizedBox(height: 2),
                                  Text(authState.error ?? 'To comment, like and reply on lectures', style: kBody),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return EsCard(
                      child: Row(
                        children: [
                          const Icon(Icons.account_circle_outlined, color: C.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: kTitle),
                                const SizedBox(height: 2),
                                const Text('Signed in with Google', style: kBody),
                              ],
                            ),
                          ),
                          TextButton(onPressed: authState.signOut, child: const Text('Sign out')),
                        ],
                      ),
                    );
                  },
                ),
                const SectionLabel('Tools'),
                PickRow(icon: '⏱️', title: 'Focus mode', lines: const ['Study timer'], onTap: () => openSitePage(context, 'Focus mode', 'focus.html')),
                PickRow(icon: '💬', title: 'Doubts', lines: const ['Ask a question'], onTap: () => openSitePage(context, 'Doubts', 'doubts.html')),
                PickRow(icon: '❤️', title: 'Support', lines: const ['Help keep everything free'], onTap: () => openSitePage(context, 'Support', 'support.html')),
                const SectionLabel('🔖 Saved'),
                if (savedLectures.isEmpty && savedMaterial.isEmpty) const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Nothing saved yet.', style: kBody)),
                for (final l in savedLectures) LectureRow(lecture: l),
                for (final m in savedMaterial) MaterialCard(item: m),
                if (data.updates.isNotEmpty) const SectionLabel('📢 Updates'),
                for (final up in data.updates)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${up.date}  ', style: const TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 13)),
                          TextSpan(text: up.text, style: kBody),
                        ],
                      ),
                    ),
                  ),
                const SectionLabel('⚙ Settings'),
                EsCard(
                  child: Row(
                    children: [
                      const Expanded(child: Text('Daily goal (minutes)', style: kTitle)),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: C.text2),
                        onPressed: () => appState.setGoal(appState.goalMin - 5),
                      ),
                      Text('${appState.goalMin}', style: kTitle),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: C.text2),
                        onPressed: () => appState.setGoal(appState.goalMin + 5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Pill(
                      label: appState.refreshing ? 'Refreshing…' : 'Refresh content',
                      icon: Icons.refresh,
                      onTap: appState.refreshing ? null : () => appState.refresh(),
                    ),
                    Pill(
                      label: 'Check for app update',
                      icon: Icons.system_update,
                      onTap: () async {
                        await appState.checkUpdate();
                        if (context.mounted) {
                          final msg = appState.update == null ? 'You have the latest version.' : 'A new version is available.';
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        }
                      },
                    ),
                    Pill(label: 'Reset my progress', icon: Icons.delete_outline, onTap: () => _confirmReset(context)),
                  ],
                ),
                const SectionLabel('Follow us'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if ((data.links['youtube'] ?? '').isNotEmpty) Pill(label: 'YouTube', icon: Icons.play_circle_outline, onTap: () => openExternal(context, data.links['youtube']!)),
                    if ((data.links['telegram'] ?? '').isNotEmpty) Pill(label: 'Telegram', icon: Icons.send, onTap: () => openExternal(context, data.links['telegram']!)),
                    if ((data.links['x'] ?? '').isNotEmpty) Pill(label: 'X', icon: Icons.open_in_new, onTap: () => openExternal(context, data.links['x']!)),
                    Pill(label: 'Website', icon: Icons.language, onTap: () => openExternal(context, kSiteBase)),
                  ],
                ),
                const SizedBox(height: 22),
                Center(
                  child: GestureDetector(
                    onLongPress: () => _showNotes(context),
                    child: Text(
                      'Emerging Sciences · app v1.0.$kBuildNumber\n${appState.offline ? 'Offline — showing saved content' : 'Content is up to date'}',
                      textAlign: TextAlign.center,
                      style: kSmall,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(child: Text('Progress is saved on this phone only.', style: kSmall)),
              ],
            ),
          );
        },
      ),
    );
  }
}
