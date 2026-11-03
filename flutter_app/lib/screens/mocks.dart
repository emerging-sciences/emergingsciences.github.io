import 'package:flutter/material.dart';

import '../app_state.dart';
import '../config.dart';
import '../theme.dart';
import '../widgets.dart';
import 'web_page.dart';

class MockListScreen extends StatelessWidget {
  final String examId;
  final String sid; // topic id or 'full'
  final String? paperId;
  const MockListScreen({super.key, required this.examId, required this.sid, this.paperId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final data = appState.data;
        final ex = data?.exam(examId);
        if (data == null || ex == null) {
          return const EsPage(title: 'Mock Tests', body: CenterMessage('Not available right now.'));
        }
        final title = sid == 'full' ? 'Full-Length Mock Tests' : (data.topic(sid)?.name ?? 'Mock Tests');
        final tests = data.mocksOf(ex, sid, paperId);
        return EsPage(
          title: title,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('${tests.length} test${tests.length == 1 ? '' : 's'}', style: kBody),
              ),
              if (tests.isEmpty) const CenterMessage('Tests for this subject are coming soon.'),
              for (final m in tests)
                PickRow(
                  icon: '▶',
                  iconColor: C.blue,
                  title: m.t,
                  lines: ['${m.q} Qs · ${m.min} min'],
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => WebPageScreen(
                      title: m.t,
                      url: '${kSiteBase}test.html?t=${Uri.encodeQueryComponent(m.id)}',
                    ),
                  )),
                ),
            ],
          ),
        );
      },
    );
  }
}
