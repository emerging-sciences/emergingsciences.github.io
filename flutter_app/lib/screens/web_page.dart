import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../config.dart';
import '../theme.dart';
import '../web_file_picker.dart';
import '../widgets.dart';

/// The website's private-doubt Google Form (same as the iframe on doubts.html). Opens in the phone's browser,
/// because uploading a photo there needs the Google login, which Google blocks inside app WebViews.
const String _kDoubtFormUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSe1m3Lpc1hyW7rem8aG6DtgBEo3TzzFiwoRF5qzhtTSV4gOjQ/viewform';

const String _hideChromeJs =
    "(function(){try{var s=document.getElementById('es-app-style');if(!s){s=document.createElement('style');"
    "s.id='es-app-style';s.textContent='.hdr,.bnav,#splash{display:none!important}body{padding-bottom:0!important}';"
    "document.head.appendChild(s);}}catch(e){}})();";

/// Gives the website page the app's current dark / light choice (the site keeps it in localStorage "es_theme"
/// and in <html data-theme>; its own sun/moon button is hidden inside the app).
String _themeJs() {
  final t = themeState.light ? 'light' : 'dark';
  return "(function(){try{localStorage.setItem('es_theme','$t');}catch(e){}"
      "try{document.documentElement.setAttribute('data-theme','$t');}catch(e){}})();";
}

/// Shows a web page inside the app (mock tests, PDFs, focus timer ...).
class WebPageScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool hideChrome; // hide the website's own header / bottom bar
  final String? downloadUrl;

  /// Optional slim bar above the page that opens [helpUrl] in the phone's browser (where the Google login works).
  final String? helpText;
  final String? helpUrl;
  const WebPageScreen({
    super.key,
    required this.title,
    required this.url,
    this.hideChrome = true,
    this.downloadUrl,
    this.helpText,
    this.helpUrl,
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
      ..setBackgroundColor(C.bg)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: _onNav,
        onPageStarted: (String url) {
          _c.runJavaScript(_themeJs());
          if (widget.hideChrome) _c.runJavaScript(_hideChromeJs);
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (String url) {
          _c.runJavaScript(_themeJs());
          if (widget.hideChrome) _c.runJavaScript(_hideChromeJs);
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
    // "Add a photo / file" buttons on web pages: without this the Android WebView ignores the tap.
    final platform = _c.platform;
    if (platform is AndroidWebViewController) {
      platform.setOnShowFileSelector((FileSelectorParams params) async {
        if (!mounted) return const <String>[];
        return pickFilesForWebView(context, params);
      });
    }
  }

  NavigationDecision _onNav(NavigationRequest req) {
    if (!req.isMainFrame) return NavigationDecision.navigate;
    final uri = Uri.tryParse(req.url);
    if (uri == null) return NavigationDecision.prevent;
    final scheme = uri.scheme;
    if (scheme == 'about' || scheme == 'data' || scheme == 'blob' || scheme == 'javascript') {
      return NavigationDecision.navigate;
    }
    // Google refuses to sign in inside an app's WebView, and Google Forms with uploads need a login:
    // those pages open in the phone's browser instead.
    final googleLogin = uri.host == 'accounts.google.com' || (uri.host == 'docs.google.com' && uri.path.startsWith('/forms'));
    if (!googleLogin && (scheme == 'http' || scheme == 'https') && isInAppHost(uri.host)) {
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
      body: Column(
        children: [
          if (widget.helpText != null && widget.helpUrl != null)
            Material(
              color: C.surface2,
              child: InkWell(
                onTap: () => openExternal(context, widget.helpUrl!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.photo_camera_outlined, size: 20, color: C.blue),
                      const SizedBox(width: 10),
                      Expanded(child: Text(widget.helpText!, style: kBody.copyWith(color: C.text))),
                      Icon(Icons.open_in_new, size: 18, color: C.text2),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _c),
                if (_loading)
                  Align(
                    alignment: Alignment.topCenter,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: C.bg,
                      valueColor: AlwaysStoppedAnimation<Color>(C.blue),
                    ),
                  ),
              ],
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
  final isDoubts = page == 'doubts.html';
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => WebPageScreen(
      title: title,
      url: '$kSiteBase$page',
      helpText: isDoubts ? 'Photo ke saath private doubt bhejna hai? Form browser me kholo' : null,
      helpUrl: isDoubts ? _kDoubtFormUrl : null,
    ),
  ));
}
