import 'package:flutter/material.dart';

import '../app_state.dart';
import '../config.dart';
import '../core/models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'lectures.dart';
import 'study_material.dart';
import 'web_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctl = TextEditingController();
  String _q = '';
  int _tab = 0; // 0 = All, 1 = Lectures, 2 = Material, 3 = Mock Tests

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  /// Mock tests are found by title, exam (JAM, GATE ...), subject / topic, or the words "mock" / "test".
  List<Mock> _findMocks(EsData data, String q) {
    final words = q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return data.mocks.where((m) {
      final ex = data.exam(m.e);
      final topic = m.s == 'full' ? null : data.topic(m.s);
      final paper = (ex != null && data.hasPapers(ex)) ? data.paper(m.s == 'full' ? m.p : topic?.p) : null;
      final hay = [m.t, 'mock test tests full length', ex?.short ?? '', ex?.name ?? '', topic?.name ?? '', paper?.name ?? '']
          .join(' ')
          .toLowerCase();
      return words.every(hay.contains);
    }).toList();
  }

  /// "Mock Tests (n)" heading + one row per test. Shown FIRST in the results, because there are only a few mock
  /// tests and they used to be pushed below every lecture and PDF.
  List<Widget> _mockSection(BuildContext context, EsData? data, List<Mock> mocks) {
    return <Widget>[
      SectionLabel('Mock Tests (${mocks.length})'),
      for (final m in mocks)
        PickRow(
          icon: '▶',
          iconColor: C.blue,
          title: m.t,
          lines: [
            [data?.exam(m.e)?.short ?? '', m.s == 'full' ? 'Full-Length' : (data?.topic(m.s)?.name ?? '')]
                .where((x) => x.isNotEmpty)
                .join(' · '),
            '${m.q} Qs · ${m.min} min',
          ],
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => WebPageScreen(
              title: m.t,
              url: '${kSiteBase}test.html?t=${Uri.encodeQueryComponent(m.id)}',
            ),
          )),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return EsPage(
      title: 'Search',
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final data = appState.data;
          final q = _q.trim().toLowerCase();
          final List<Lecture> lectures = (data == null || q.isEmpty)
              ? <Lecture>[]
              : data.lectures.where((l) => '${l.t} ${l.n} ${data.topic(l.s)?.name ?? ''}'.toLowerCase().contains(q)).toList();
          final List<StudyMaterial> material = (data == null || q.isEmpty)
              ? <StudyMaterial>[]
              : data.material.where((m) => '${m.t} ${m.d} ${m.k}'.toLowerCase().contains(q)).toList();
          final List<Mock> mocks = (data == null || q.isEmpty) ? <Mock>[] : _findMocks(data, q);
          final labels = <String>[
            'All (${lectures.length + material.length + mocks.length})',
            'Lectures (${lectures.length})',
            'Material (${material.length})',
            'Mock Tests (${mocks.length})',
          ];
          final showLec = _tab == 0 || _tab == 1;
          final showMat = _tab == 0 || _tab == 2;
          final showMock = _tab == 0 || _tab == 3;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              TextField(
                controller: _ctl,
                autofocus: true,
                style: TextStyle(color: C.text),
                cursorColor: C.blue,
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: 'Search lectures, notes and mock tests…',
                  hintStyle: TextStyle(color: C.text3),
                  prefixIcon: Icon(Icons.search, color: C.text3),
                  filled: true,
                  fillColor: C.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: C.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: C.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: C.blue),
                  ),
                ),
              ),
              if (q.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ChipRow(
                    labels: labels,
                    selected: labels[_tab],
                    onSelect: (l) {
                      final i = labels.indexOf(l);
                      setState(() => _tab = i < 0 ? 0 : i);
                    },
                  ),
                ),
                if (showMock && mocks.isNotEmpty) ..._mockSection(context, data, mocks),
                if (showLec) ...[
                  SectionLabel('Lectures (${lectures.length})'),
                  for (final l in lectures) LectureRow(lecture: l),
                ],
                if (showMat) ...[
                  SectionLabel('Material (${material.length})'),
                  for (final m in material) MaterialCard(item: m),
                ],
                if (showMock && mocks.isEmpty) SectionLabel('Mock Tests (0)'),
              ],
            ],
          );
        },
      ),
    );
  }
}
