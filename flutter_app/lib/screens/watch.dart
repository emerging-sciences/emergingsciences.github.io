import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../app_state.dart';
import '../config.dart';
import '../core/models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'lectures.dart';
import 'study_material.dart';

const String _playerHtml = r'''<!DOCTYPE html><html><head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>html,body{margin:0;padding:0;height:100%;background:#000;overflow:hidden}
#p{position:absolute;top:0;left:0;right:0;bottom:0;width:100%;height:100%}</style></head>
<body><div id="p"></div>
<script>
var player;
function post(m){try{Native.postMessage(m)}catch(e){}}
var tag=document.createElement('script');tag.src='https://www.youtube.com/iframe_api';document.head.appendChild(tag);
function onYouTubeIframeAPIReady(){
  player=new YT.Player('p',{videoId:'__VID__',width:'100%',height:'100%',
    playerVars:{rel:0,playsinline:1,fs:0,modestbranding:1},
    events:{onReady:function(){post('ready')},
            onStateChange:function(e){post('state:'+e.data)},
            onError:function(e){post('error:'+e.data)}}});
}
function setRate(r){try{player.setPlaybackRate(r)}catch(e){}}
</script></body></html>''';

class WatchScreen extends StatefulWidget {
  final String lectureId;
  final String? examId;
  const WatchScreen({super.key, required this.lectureId, this.examId});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  late final WebViewController _wc;
  final GlobalKey _videoKey = GlobalKey();
  Timer? _tick;
  double _rate = 1.0;
  bool _ended = false;
  bool _failed = false;
  bool _systemLandscape = false;

  Lecture? get _lec => appState.data?.lecture(widget.lectureId);

  @override
  void initState() {
    super.initState();
    final vid = (_lec?.yt ?? '').replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
    _wc = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..addJavaScriptChannel('Native', onMessageReceived: _onMessage)
      ..loadHtmlString(_playerHtml.replaceAll('__VID__', vid), baseUrl: kSiteBase);
  }

  void _onMessage(JavaScriptMessage m) {
    final msg = m.message;
    if (msg == 'state:1') {
      _tick ??= Timer.periodic(const Duration(seconds: 1), (_) => appState.addStudySecond());
      if (_ended && mounted) setState(() => _ended = false);
    } else if (msg == 'state:0') {
      _stopTick();
      final l = _lec;
      if (l != null) appState.setDone(l.id, true);
      if (mounted) setState(() => _ended = true);
    } else if (msg.startsWith('state:')) {
      _stopTick();
    } else if (msg.startsWith('error:')) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _stopTick() {
    _tick?.cancel();
    _tick = null;
    appState.flushStudy();
  }

  @override
  void dispose() {
    _tick?.cancel();
    _tick = null;
    appState.flushStudy(notify: false);
    scheduleMicrotask(appState.touch);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _syncSystemUi(bool landscape) {
    if (landscape == _systemLandscape) return;
    _systemLandscape = landscape;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(landscape ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
    });
  }

  void _enterFullscreen() {
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void _exitFullscreen() {
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    });
  }

  void _setRate(double r) {
    setState(() => _rate = r);
    _wc.runJavaScript('setRate($r)');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final data = appState.data;
        final l = _lec;
        if (data == null || l == null) {
          return const EsPage(title: 'Lecture', body: CenterMessage('Lecture not found.'));
        }
        final landscape = MediaQuery.of(context).orientation == Orientation.landscape;
        _syncSystemUi(landscape);
        final video = KeyedSubtree(key: _videoKey, child: WebViewWidget(controller: _wc));

        if (landscape) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Positioned.fill(child: video),
                Positioned(
                  top: 8,
                  left: 8,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                      onPressed: _exitFullscreen,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final examId = widget.examId ?? data.examOf(l.s)?.id;
        final topic = data.topic(l.s);
        final siblings = data.lecturesOf(l.s, examId: examId);
        final idx = siblings.indexWhere((x) => x.id == l.id);
        final next = (idx >= 0 && idx + 1 < siblings.length) ? siblings[idx + 1] : null;
        final upNext = idx >= 0 ? siblings.skip(idx + 1).take(5).toList() : <Lecture>[];
        final done = appState.isDone(l.id);
        final saved = appState.isSaved(l.id);

        return Scaffold(
          backgroundColor: C.bg,
          appBar: AppBar(
            backgroundColor: C.bg,
            surfaceTintColor: Colors.transparent,
            foregroundColor: C.text,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(l.n, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            actions: [
              IconButton(icon: const Icon(Icons.fullscreen), onPressed: _enterFullscreen),
            ],
          ),
          body: Column(
            children: [
              AspectRatio(aspectRatio: 16 / 9, child: video),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: [
                    Text(l.t, style: const TextStyle(color: C.text, fontSize: 18, fontWeight: FontWeight.w700, height: 1.3)),
                    const SizedBox(height: 4),
                    Text(topic?.name ?? '', style: kBody),
                    const SizedBox(height: 14),
                    if (_failed)
                      EsCard(
                        onTap: () => openExternal(context, 'https://youtu.be/${Uri.encodeComponent(l.yt)}'),
                        child: const Row(
                          children: [
                            Icon(Icons.open_in_new, color: C.orange),
                            SizedBox(width: 12),
                            Expanded(child: Text('This video could not be played here. Tap to open it in YouTube.', style: kBody)),
                          ],
                        ),
                      ),
                    if (_ended && next != null)
                      EsCard(
                        onTap: () => openLecture(context, next, examId, replace: true),
                        child: Row(
                          children: [
                            const Icon(Icons.skip_next, color: C.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Lecture completed ✅  Play next', style: kTitle),
                                  const SizedBox(height: 2),
                                  Text('${next.n} · ${next.t}', maxLines: 2, overflow: TextOverflow.ellipsis, style: kBody),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Pill(
                          label: done ? 'Completed' : 'Mark complete',
                          icon: done ? Icons.check_circle : Icons.radio_button_unchecked,
                          filled: done,
                          onTap: () => appState.toggleDone(l.id),
                        ),
                        Pill(
                          label: saved ? 'Saved' : 'Save',
                          icon: saved ? Icons.bookmark : Icons.bookmark_border,
                          onTap: () => appState.toggleSaved(l.id),
                        ),
                        Pill(
                          label: 'Copy link',
                          icon: Icons.link,
                          onTap: () => copyText(context, '${kSiteBase}watch.html?id=${l.id}', 'Link copied'),
                        ),
                        if (examId != null && topic != null)
                          Pill(
                            label: 'Notes',
                            icon: Icons.menu_book,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (_) => MaterialListScreen(examId: examId, topicId: topic.id),
                            )),
                          ),
                        if (next != null)
                          Pill(
                            label: 'Next',
                            icon: Icons.skip_next,
                            onTap: () => openLecture(context, next, examId, replace: true),
                          ),
                        Pill(
                          label: 'YouTube',
                          icon: Icons.open_in_new,
                          onTap: () => openExternal(context, 'https://youtu.be/${Uri.encodeComponent(l.yt)}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Speed', style: kSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final r in const [0.75, 1.0, 1.25, 1.5, 2.0])
                          Pill(
                            label: r == r.roundToDouble() ? '${r.toInt()}x' : '${r}x',
                            filled: _rate == r,
                            onTap: () => _setRate(r),
                          ),
                      ],
                    ),
                    if (upNext.isNotEmpty) const SectionLabel('Up next'),
                    for (final u in upNext) LectureRow(lecture: u, examId: examId, replace: true),
                    if (upNext.isEmpty && idx >= 0) const Padding(padding: EdgeInsets.only(top: 18), child: Text('Last lecture of this subject 🎉', style: kBody)),
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
