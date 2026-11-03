import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'browse.dart';
import 'search.dart';
import 'web_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: appState,
          builder: (context, _) {
            final data = appState.data;
            if (data == null) return const CenterMessage('Loading…');
            final now = DateTime.now();
            final goal = appState.goalSeconds;
            final today = appState.todaySeconds;
            final up = data.upcomingExam(now);
            final u = appState.update;
            return RefreshIndicator(
              onRefresh: appState.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/logo-icon.png', width: 42, height: 42),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Emerging Sciences', style: TextStyle(color: C.text, fontSize: 19, fontWeight: FontWeight.w700)),
                            Text('Free lectures · notes · mock tests', style: kSmall),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: C.text),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SearchScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (u != null)
                    EsCard(
                      onTap: () => openExternal(context, u.apk),
                      child: Row(
                        children: [
                          const Icon(Icons.system_update, color: C.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('New app version available${u.name.isEmpty ? '' : ' · v${u.name}'}', style: kTitle),
                                const SizedBox(height: 2),
                                Text(u.notes.isEmpty ? 'Tap to download the update.' : u.notes, style: kBody),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (appState.offline)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(Icons.wifi_off, size: 16, color: C.orange),
                          SizedBox(width: 8),
                          Expanded(child: Text('Offline — showing saved content. Pull down to refresh.', style: kSmall)),
                        ],
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: EsCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Daily goal', style: kTitle),
                              const SizedBox(height: 10),
                              Bar(value: goal == 0 ? 0.0 : today / goal),
                              const SizedBox(height: 8),
                              Text('${today ~/ 60} / ${appState.goalMin} min', style: kSmall),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: EsCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🔥 ${appState.streak} days', style: kTitle),
                              const SizedBox(height: 10),
                              const Text('Study streak', style: kSmall),
                              const SizedBox(height: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (up != null)
                    EsCard(
                      onTap: () => pushBrowse(context, 'lectures', up.id),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: C.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${data.daysLeft(up, now)} days to ${up.short}', style: kTitle),
                                const SizedBox(height: 2),
                                Text('${up.dateText}${up.note.isEmpty ? '' : ' (${up.note})'}', style: kBody),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      _Stat(data.lectures.length, 'Lectures'),
                      const SizedBox(width: 8),
                      _Stat(data.material.length, 'Notes & PDFs'),
                      const SizedBox(width: 8),
                      _Stat(data.mocks.length, 'Mock Tests'),
                      const SizedBox(width: 8),
                      _Stat(data.exams.length, 'Exams'),
                    ],
                  ),
                  const SectionLabel('Target exams'),
                  for (final e in data.exams) _ExamCard(exam: e, data: data, now: now),
                  const SizedBox(height: 6),
                  Center(
                    child: Pill(
                      label: 'Support Emerging Sciences',
                      icon: Icons.favorite,
                      onTap: () => openSitePage(context, 'Support', 'support.html'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.border),
        ),
        child: Column(
          children: [
            Text('$value', style: const TextStyle(color: C.blue, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: C.text2, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final EsData data;
  final DateTime now;
  const _ExamCard({required this.exam, required this.data, required this.now});

  @override
  Widget build(BuildContext context) {
    final e = exam;
    final color = hexColor(e.color, C.blue);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: EsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      e.tag.isEmpty ? e.short : e.tag,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w800, height: 1.15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name, style: kTitle.copyWith(fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(e.body, style: kSmall),
                    ],
                  ),
                ),
              ],
            ),
            if (e.desc.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(e.desc, maxLines: 4, overflow: TextOverflow.ellipsis, style: kBody),
              ),
            const SizedBox(height: 10),
            Text(data.countdownText(e, now), style: const TextStyle(color: C.blue, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('📅 ${e.dateText}${e.note.isEmpty ? '' : ' · ${e.note}'}', style: kSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Pill(label: 'Lectures', icon: Icons.play_circle_outline, filled: true, onTap: () => pushBrowse(context, 'lectures', e.id)),
                Pill(label: 'Material', icon: Icons.menu_book_outlined, onTap: () => pushBrowse(context, 'material', e.id)),
                Pill(label: 'Mock', icon: Icons.quiz_outlined, onTap: () => pushBrowse(context, 'mock', e.id)),
                if (e.site.isNotEmpty) Pill(label: 'Official site', icon: Icons.open_in_new, onTap: () => openExternal(context, e.site)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
