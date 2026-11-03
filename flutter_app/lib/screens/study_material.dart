import 'package:flutter/material.dart';

import '../app_state.dart';
import '../core/models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'web_page.dart';

String _driveDownload(String id) => 'https://drive.google.com/uc?export=download&id=$id';

/// One study-material PDF (Notes / PYQ / Practice).
class MaterialCard extends StatelessWidget {
  final StudyMaterial item;
  const MaterialCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final m = item;
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final saved = appState.isSaved(m.id);
        final topicName = appState.data?.topic(m.s)?.name ?? '';
        return EsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.t, style: kTitle),
              if (m.d.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(m.d, style: kBody),
                ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Tag(m.k),
                  if (topicName.isNotEmpty) Tag(topicName),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Pill(
                    label: 'Read',
                    icon: Icons.menu_book,
                    filled: true,
                    onTap: () => openDrivePdf(context, m.t, m.drive),
                  ),
                  Pill(
                    label: 'Download',
                    icon: Icons.download,
                    onTap: () => openExternal(context, _driveDownload(m.drive)),
                  ),
                  Pill(
                    label: saved ? 'Saved' : 'Save',
                    icon: saved ? Icons.bookmark : Icons.bookmark_border,
                    onTap: () => appState.toggleSaved(m.id),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class MaterialListScreen extends StatefulWidget {
  final String examId;
  final String topicId;
  const MaterialListScreen({super.key, required this.examId, required this.topicId});

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  String _kind = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final data = appState.data;
        final topic = data?.topic(widget.topicId);
        if (data == null || topic == null) {
          return const EsPage(title: 'Study Material', body: CenterMessage('This subject is not available right now.'));
        }
        final all = data.materialOf(topic.id, examId: widget.examId);
        final kinds = <String>[];
        for (final m in all) {
          if (!kinds.contains(m.k)) kinds.add(m.k);
        }
        final shown = all.where((m) => _kind == 'All' || m.k == _kind).toList();
        return EsPage(
          title: topic.name,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('${all.length} PDF${all.length == 1 ? '' : 's'}', style: kBody),
              ),
              if (kinds.length > 1) ...[
                ChipRow(
                  labels: ['All', ...kinds],
                  selected: _kind,
                  onSelect: (v) => setState(() => _kind = v),
                ),
                const SizedBox(height: 14),
              ],
              if (shown.isEmpty) const Padding(padding: EdgeInsets.only(top: 40), child: CenterMessage('PDFs for this subject are coming soon.')),
              for (final m in shown) MaterialCard(item: m),
            ],
          ),
        );
      },
    );
  }
}

/// Buttons for a file that is either a Google Drive file (opens in the app) or a plain web link.
List<Widget> _fileButtons(BuildContext context, String label, String title, String url, String drive, {bool filled = false}) {
  if (drive.isNotEmpty) {
    return [
      Pill(label: label, icon: Icons.menu_book, filled: filled, onTap: () => openDrivePdf(context, title, drive)),
      Pill(label: 'Download', icon: Icons.download, onTap: () => openExternal(context, _driveDownload(drive))),
    ];
  }
  if (url.isNotEmpty) {
    return [
      Pill(label: label, icon: Icons.open_in_new, filled: filled, onTap: () => openExternal(context, url)),
    ];
  }
  return <Widget>[];
}

class SyllabusScreen extends StatelessWidget {
  final String examId;
  final String? paperId;
  const SyllabusScreen({super.key, required this.examId, this.paperId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final data = appState.data;
        final ex = data?.exam(examId);
        if (data == null || ex == null) {
          return const EsPage(title: 'Syllabus', body: CenterMessage('Not available right now.'));
        }
        final pp = data.paper(paperId);
        final rows = data.syllabusOf(examId, paperId);
        return EsPage(
          title: '${ex.short}${pp != null ? ' ${pp.name}' : ''} Syllabus',
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('${ex.name} · ${rows.length} document${rows.length == 1 ? '' : 's'}', style: kBody),
              ),
              if (rows.isEmpty) const CenterMessage('Syllabus for this exam is coming soon.'),
              for (final r in rows)
                EsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.t, style: kTitle),
                      if (r.src.isNotEmpty || r.n.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text([r.src, r.n].where((x) => x.isNotEmpty).join(' · '), style: kBody),
                        ),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8, children: _fileButtons(context, 'Open', r.t, r.url, r.drive, filled: true)),
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

class PyqScreen extends StatefulWidget {
  final String examId;
  final String? paperId;
  const PyqScreen({super.key, required this.examId, this.paperId});

  @override
  State<PyqScreen> createState() => _PyqScreenState();
}

class _PyqScreenState extends State<PyqScreen> {
  String _group = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final data = appState.data;
        final ex = data?.exam(widget.examId);
        if (data == null || ex == null) {
          return const EsPage(title: 'PYQs', body: CenterMessage('Not available right now.'));
        }
        final pp = data.paper(widget.paperId);
        final all = data.pyqsOf(widget.examId, widget.paperId);
        final groups = <String>[];
        for (final r in all) {
          if (r.g.isNotEmpty && !groups.contains(r.g)) groups.add(r.g);
        }
        final shown = all.where((r) => _group == 'All' || r.g == _group).toList();
        final portal = data.portalOf(widget.examId, widget.paperId);
        var yearsText = '';
        if (all.isNotEmpty) {
          final ys = all.map((r) => r.y).toList()..sort();
          yearsText = ys.first == ys.last ? '${ys.first}' : '${ys.first}–${ys.last}';
        }
        return EsPage(
          title: '${ex.short}${pp != null ? ' ${pp.name}' : ''} · PYQs',
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  all.isNotEmpty
                      ? '${all.length} paper${all.length == 1 ? '' : 's'} · $yearsText'
                      : 'Year-wise PDFs for this exam are being added. Use the official page below meanwhile.',
                  style: kBody,
                ),
              ),
              if (groups.length > 1) ...[
                ChipRow(
                  labels: ['All', ...groups],
                  selected: _group,
                  onSelect: (v) => setState(() => _group = v),
                ),
                const SizedBox(height: 14),
              ],
              for (final r in shown)
                EsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${r.y}${r.g.isNotEmpty ? ' · ${r.g}' : ''}', style: kTitle),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${r.t}${r.n.isNotEmpty ? ' — ${r.n}' : ''}', style: kBody),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._fileButtons(context, 'Paper', '${r.t} — Paper', r.qp, r.qpDrive, filled: true),
                          ..._fileButtons(context, 'Key', '${r.t} — Key', r.key, r.keyDrive),
                        ],
                      ),
                    ],
                  ),
                ),
              if (portal != null)
                EsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🌐 Official source', style: kTitle),
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('All years and the latest papers are always on the official page.', style: kBody),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Pill(
                            label: portal.label.isEmpty ? 'Official page' : portal.label,
                            icon: Icons.open_in_new,
                            filled: true,
                            onTap: () => openExternal(context, portal.url),
                          ),
                          if (portal.more.isNotEmpty)
                            Pill(
                              label: portal.moreLabel.isEmpty ? 'More' : portal.moreLabel,
                              icon: Icons.open_in_new,
                              onTap: () => openExternal(context, portal.more),
                            ),
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
