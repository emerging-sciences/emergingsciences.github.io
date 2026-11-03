import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config.dart';
import '../theme.dart';
import '../widgets.dart';

const String _hideChromeJs =
    "(function(){try{var s=document.getElementById('es-app-style');if(!s){s=document.createElement('style');"
    "s.id='es-app-style';s.textContent='.hdr,.bnav,#splash{display:none!important}body{padding-bottom:0!important}';"
    "document.head.appendChild(s);}}catch(e){}})();";

/// Shows a web page inside the app (mock tests, PDFs, focus timer ...).
class WebPageScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool hideChrome; // hide the website's own header / bottom bar
  final String? downloadUrl;
  const WebPageScreen({
    super.key,
    required this.title,
    required this.url,
    this.hideChrome = true,
    this.downloadUrl,
  });

  @override
  State<WebPageScreen> createState() => _WebPageScreenState();
}

class _WebPageScreenState extends State<WebPageScreen> {
  late final WebViewController _c;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: _onNav,
        onPageStarted: (String url) {
          if (widget.hideChrome) _c.runJavaScript(_hideChromeJs);
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (String url) {
          if (widget.hideChrome) _c.runJavaScript(_hideChromeJs);
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  NavigationDecision _onNav(NavigationRequest req) {
    if (!req.isMainFrame) return NavigationDecision.navigate;
    final uri = Uri.tryParse(req.url);
    if (uri == null) return NavigationDecision.prevent;
    final scheme = uri.scheme;
    if (scheme == 'about' || scheme == 'data' || scheme == 'blob' || scheme == 'javascript') {
      return NavigationDecision.navigate;
    }
    if ((scheme == 'http' || scheme == 'https') && isInAppHost(uri.host)) {
      return NavigationDecision.navigate;
    }
    openExternal(context, req.url);
    return NavigationDecision.prevent;
  }

  @override
  Widget build(BuildContext context) {
    final dl = widget.downloadUrl;
    return EsPage(
      title: widget.title,
      actions: [
        if (dl != null)
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => openExternal(context, dl),
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _c.reload(),
        ),
      ],
      body: Stack(
        children: [
          WebViewWidget(controller: _c),
          if (_loading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: C.bg,
                valueColor: AlwaysStoppedAnimation<Color>(C.blue),
              ),
            ),
        ],
      ),
    );
  }
}

/// Opens a Google Drive file in the in-app reader.
void openDrivePdf(BuildContext context, String title, String driveId) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => WebPageScreen(
      title: title,
      url: 'https://drive.google.com/file/d/$driveId/preview',
      hideChrome: false,
      downloadUrl: 'https://drive.google.com/uc?export=download&id=$driveId',
    ),
  ));
}

/// Opens one of the website's own pages inside the app (without the site's header and bottom bar).
void openSitePage(BuildContext context, String title, String page) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => WebPageScreen(title: title, url: '$kSiteBase$page'),
  ));
}
