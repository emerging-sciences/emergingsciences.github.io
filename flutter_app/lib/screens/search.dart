import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'lectures.dart';
import 'study_material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
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
                  hintText: 'Search lectures and notes…',
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
                SectionLabel('Lectures (${lectures.length})'),
                for (final l in lectures) LectureRow(lecture: l),
                SectionLabel('Material (${material.length})'),
                for (final m in material) MaterialCard(item: m),
              ],
            ],
          );
        },
      ),
    );
  }
}
