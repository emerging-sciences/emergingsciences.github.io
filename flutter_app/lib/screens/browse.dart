import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'lectures.dart';
import 'mocks.dart';
import 'search.dart';
import 'study_material.dart';

String pageTitle(String page) {
  if (page == 'lectures') return 'Lectures';
  if (page == 'material') return 'Study Material';
  return 'Mock Tests';
}

void pushBrowse(BuildContext context, String page, String examId, {String? paperId}) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => BrowseScreen(page: page, examId: examId, paperId: paperId),
  ));
}

/// Tab root: "Step 1 — choose your exam".
class ExamChooser extends StatelessWidget {
  final String page; // lectures | material | mock
  const ExamChooser({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return EsPage(
      title: pageTitle(page),
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
          final now = DateTime.now();
          return RefreshIndicator(
            onRefresh: appState.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('Step 1 — choose your exam', style: kBody),
                ),
                for (final e in data.exams)
                  PickRow(
                    icon: e.short.isEmpty ? e.id.toUpperCase() : e.short,
                    iconColor: hexColor(e.color, C.blue),
                    title: e.name,
                    lines: [
                      e.body,
                      data.examPickLabel(page, e),
                      data.countdownText(e, now),
                    ],
                    onTap: () => pushBrowse(context, page, e.id),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Exam -> (subject) -> topic list, for lectures / material / mock tests.
class BrowseScreen extends StatelessWidget {
  final String page;
  final String examId;
  final String? paperId;
  const BrowseScreen({super.key, required this.page, required this.examId, this.paperId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final data = appState.data;
        final ex = data?.exam(examId);
        if (data == null || ex == null) {
          return EsPage(title: pageTitle(page), body: const CenterMessage('This exam is not available right now.'));
        }
        final now = DateTime.now();
        final status = '${data.countdownText(ex, now)} (${ex.dateText}${ex.note.isEmpty ? '' : ', ${ex.note}'})';
        final hp = data.hasPapers(ex);

        // Step 2: choose a subject (exams that have papers)
        if (hp && paperId == null) {
          return EsPage(
            title: ex.name,
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('Step 2 — choose your subject · $status', style: kBody)),
                for (final pp in data.papersOf(ex))
                  PickRow(
                    icon: pp.icon,
                    title: pp.name,
                    lines: [data.paperPickLabel(page, ex, pp)],
                    onTap: () => pushBrowse(context, page, examId, paperId: pp.id),
                  ),
              ],
            ),
          );
        }

        // Step 3: syllabus / PYQs / topics
        final pp = hp ? data.paper(paperId) : null;
        final p = hp ? paperId : null;
        final topics = data.topicsOf(ex, p);
        final children = <Widget>[];
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${pp != null ? 'Step 3 — choose Syllabus, PYQs or a topic' : 'Choose a topic'} · $status',
            style: kBody,
          ),
        ));

        if (page == 'material' || p != null) {
          final sy = data.syllabusOf(examId, p);
          final py = data.pyqsOf(examId, p);
          final portal = data.portalOf(examId, p);
          children.add(PickRow(
            icon: '📋',
            title: 'Syllabus',
            lines: [sy.isEmpty ? 'Coming soon' : '${sy.length} document${sy.length == 1 ? '' : 's'}'],
            onTap: sy.isEmpty
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => SyllabusScreen(examId: examId, paperId: p),
                    )),
          ));
          final pyqLine = py.isNotEmpty
              ? '${py.length} paper${py.length == 1 ? '' : 's'} · ${_yearRange(py)}'
              : (portal != null ? 'Official papers page' : 'Coming soon');
          children.add(PickRow(
            icon: '🗂️',
            title: 'PYQs · Year-wise',
            lines: [pyqLine],
            onTap: (py.isEmpty && portal == null)
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => PyqScreen(examId: examId, paperId: p),
                    )),
          ));
        }

        if (page == 'mock') {
          final full = data.mocksOf(ex, 'full', p);
          children.add(PickRow(
            icon: '📝',
            title: 'Full-Length Mock Tests',
            lines: [full.isEmpty ? 'Coming soon' : '${full.length} test${full.length == 1 ? '' : 's'}'],
            onTap: full.isEmpty
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => MockListScreen(examId: examId, sid: 'full', paperId: p),
                    )),
          ));
        }

        for (final t in topics) {
          final badge = data.topicBadge(page, ex, t, p);
          VoidCallback? tap;
          if (badge != null) {
            tap = () => _openTopic(context, data, ex, t, p);
          }
          double? progress;
          if (page == 'lectures' && badge != null) {
            final all = data.lecturesOf(t.id, examId: examId);
            final c = all.where((l) => appState.isDone(l.id)).length;
            progress = all.isEmpty ? 0.0 : c / all.length;
            children.add(PickRow(
              icon: t.icon,
              title: t.name,
              lines: ['$badge · $c/${all.length} completed'],
              progress: progress,
              onTap: tap,
            ));
          } else {
            children.add(PickRow(
              icon: t.icon,
              title: t.name,
              lines: [badge ?? 'Coming soon'],
              onTap: tap,
            ));
          }
        }

        return EsPage(
          title: pp != null ? '${pp.icon} ${pp.name}' : ex.name,
          body: RefreshIndicator(
            onRefresh: appState.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: children,
            ),
          ),
        );
      },
    );
  }

  String _yearRange(List<Pyq> py) {
    var lo = py.first.y;
    var hi = py.first.y;
    for (final r in py) {
      if (r.y < lo) lo = r.y;
      if (r.y > hi) hi = r.y;
    }
    return lo == hi ? '$lo' : '$lo–$hi';
  }

  void _openTopic(BuildContext context, EsData data, Exam ex, Topic t, String? p) {
    Widget screen;
    if (page == 'lectures') {
      screen = LectureListScreen(examId: ex.id, topicId: t.id);
    } else if (page == 'material') {
      screen = MaterialListScreen(examId: ex.id, topicId: t.id);
    } else {
      screen = MockListScreen(examId: ex.id, sid: t.id, paperId: p);
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}
