import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'watch.dart';

void openLecture(BuildContext context, Lecture l, String? examId, {bool replace = false}) {
  final route = MaterialPageRoute<void>(builder: (_) => WatchScreen(lectureId: l.id, examId: examId));
  if (replace) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}

/// One lecture in a list: thumbnail, title, Theory/Practice, done / saved marks.
class LectureRow extends StatelessWidget {
  final Lecture lecture;
  final String? examId;
  final bool replace;
  const LectureRow({super.key, required this.lecture, this.examId, this.replace = false});

  @override
  Widget build(BuildContext context) {
    final l = lecture;
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final done = appState.isDone(l.id);
        final saved = appState.isSaved(l.id);
        return EsCard(
          padding: const EdgeInsets.all(10),
          onTap: () => openLecture(context, l, examId, replace: replace),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 124,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://i.ytimg.com/vi/${l.yt}/mqdefault.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(color: C.surface2),
                        ),
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xC7000000),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(l.n, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.t, maxLines: 3, overflow: TextOverflow.ellipsis, style: kTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Tag(l.isPractice ? 'Practice' : 'Theory'),
                        const SizedBox(width: 8),
                        if (done) const Icon(Icons.check_circle, size: 16, color: C.green),
                        if (saved) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.bookmark, size: 16, color: C.orange)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LectureListScreen extends StatefulWidget {
  final String examId;
  final String topicId;
  const LectureListScreen({super.key, required this.examId, required this.topicId});

  @override
  State<LectureListScreen> createState() => _LectureListScreenState();
}

class _LectureListScreenState extends State<LectureListScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final data = appState.data;
        final topic = data?.topic(widget.topicId);
        if (data == null || topic == null) {
          return const EsPage(title: 'Lectures', body: CenterMessage('This subject is not available right now.'));
        }
        final all = data.lecturesOf(topic.id, examId: widget.examId);
        final doneCount = all.where((l) => appState.isDone(l.id)).length;
        final shown = all.where((l) {
          if (_filter == 'Theory') return !l.isPractice;
          if (_filter == 'Practice') return l.isPractice;
          return true;
        }).toList();
        return EsPage(
          title: topic.name,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('$doneCount of ${all.length} completed', style: kBody),
              ),
              ChipRow(
                labels: const ['All', 'Theory', 'Practice'],
                selected: _filter,
                onSelect: (v) => setState(() => _filter = v),
              ),
              const SizedBox(height: 14),
              if (shown.isEmpty) const Padding(padding: EdgeInsets.only(top: 40), child: CenterMessage('No lectures here yet.')),
              for (final l in shown) LectureRow(lecture: l, examId: widget.examId),
            ],
          ),
        );
      },
    );
  }
}
